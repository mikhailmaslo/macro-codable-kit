//
//  EncodableBuilder+Instance.swift
//
//
//  Created by Mikhail Maslo on 07.10.23.
//

import MacroToolkit

extension EncodableBuilder {
    static func verify(
        accessModifier: AccessModifier?,
        strategy: CodableStrategy,
        instance: Instance
    ) throws -> EncodableBuilder.BuildingData {
        try EncodableBuilder.BuildingData(
            accessModifier: accessModifier,
            strategy: strategy,
            items: instance.members
                .compactMap { member -> EncodableBuilder.BuildingData.Item? in
                    guard
                        let variable = member.asVariable,
                        !variable.isStatic
                    else {
                        return nil
                    }

                    let knownAttributes = variable.knownAttributes()
                    try variable.verify(knownAttributes)

                    guard variable.isStoredProperty else {
                        return nil
                    }

                    // Skip coding if omitCoding is specified
                    guard knownAttributes[.omitCoding] == nil else {
                        return nil
                    }

                    return makeItem(variable: variable, strategy: strategy, knownAttributes: knownAttributes)
                }
        )
    }

    private static func makeItem(
        variable: Variable,
        strategy: CodableStrategy,
        knownAttributes: Variable.AllKnownAttributes
    ) -> EncodableBuilder.BuildingData.Item? {
        guard
            let binding = variable.bindings.first,
            let identifier = binding.identifier,
            let type = binding.type
        else {
            assertionFailure("`Variable.verify(...)` should've caught it")
            return nil
        }

        let function: FunctionBuilder
        if let customCoding = knownAttributes[.customCoding]?.first as? CustomCoding {
            /*
             static func \(customCoding.codingNameType)<K, Element: Decodable>(
             _: [Element].Type,
             forKey key: KeyedDecodingContainer<K>.Key,
             container: KeyedDecodingContainer<K>
             ) throws
             */
            function = FunctionBuilder(
                name: "CustomCodingEncoding.\(customCoding.codingNameType.lowercasingFirstLetter())",
                parameters: [
                    (nil, "self.\(identifier)"),
                    ("forKey", ".\(identifier)"),
                    ("container", "&container"),
                ]
            )
        } else if knownAttributes[.valueStrategy] != nil {
            /*
             static func encode<K, Strategy>(
             _ value: Bool,
             forKey key: KeyedEncodingContainer<K>.Key,
             container: inout KeyedEncodingContainer<K>,
             strategy: Strategy.Type
             ) throws
             where Strategy: ValueCodableStrategy,
             Strategy.Value == Bool
             */
            var parameters: FunctionBuilder.Params = [
                (nil, "self.\(identifier)"),
                ("forKey", ".\(identifier)"),
                ("container", "&container"),
            ]

            if let strategy = knownAttributes[.valueStrategy]?.first as? ValueStrategy {
                parameters.append(("strategy", "\(strategy.strategyType).self"))
            }

            function = FunctionBuilder(
                name: "CustomCodingEncoding.encode",
                parameters: parameters
            )
        } else {
            /*
             // keyed
             func decode(_ type: String.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> String

             // single
             func decode(_ type: String.Type) throws -> String
             */
            switch strategy {
            case .singleValue:
                function = FunctionBuilder(
                    name: type.isOptional ? "self.\(identifier).encodeIfPresent" : "self.\(identifier).encode",
                    parameters: [
                        ("to", "encoder"),
                    ]
                )
            case .codingKeys:
                function = FunctionBuilder(
                    name: type.isOptional ? "container.encodeIfPresent" : "container.encode",
                    parameters: [
                        (nil, "self.\(identifier)"),
                        ("forKey", ".\(identifier)"),
                    ]
                )
            }
        }

        return EncodableBuilder.BuildingData.Item(identifier: identifier, function: function.build())
    }
}
