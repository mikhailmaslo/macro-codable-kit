//
//  DecodableBuilder+Instance.swift
//
//
//  Created by Mikhail Maslo on 07.10.23.
//

import MacroToolkit

extension DecodableBuilder {
    static func verify(
        accessModifier: AccessModifier?,
        strategy: CodableStrategy,
        instance: Instance
    ) throws -> DecodableBuilder.BuildingData {
        try DecodableBuilder.BuildingData(
            accessModifier: accessModifier,
            strategy: strategy,
            items: instance.members
                .compactMap { member -> DecodableBuilder.BuildingData.Item? in
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
    ) -> DecodableBuilder.BuildingData.Item? {
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
             ) throws -> [Element]
             */
            function = FunctionBuilder(
                name: "CustomCodingDecoding.\(customCoding.codingNameType.lowercasingFirstLetter())",
                parameters: [
                    (nil, type.typeDescription(preservingOptional: true)),
                    ("forKey", ".\(identifier)"),
                    ("container", "container"),
                ]
            )
        } else if knownAttributes[.defaultValue] != nil || knownAttributes[.valueStrategy] != nil {
            /*
             static func decode<K, T, Provider, Strategy>(
             _ type: T.Type,
             forKey key: KeyedDecodingContainer<K>.Key,
             container: KeyedDecodingContainer<K>,
             strategy: Strategy.Type,
             provider _: Provider.Type
             ) throws -> T
             where Strategy: ValueCodableStrategy,
             Strategy.Value == T,
             Provider: DefaultValueProvider,
             Provider.DefaultValue == T,
             T: Decodable
             */
            var parameters: FunctionBuilder.Params = [
                (nil, type.typeDescription(preservingOptional: true)),
                ("forKey", ".\(identifier)"),
                ("container", "container"),
            ]

            if let strategy = knownAttributes[.valueStrategy]?.first as? ValueStrategy {
                parameters.append(("strategy", "\(strategy.strategyType).self"))
            }

            if let defaultValue = knownAttributes[.defaultValue]?.first as? DefaultValue {
                parameters.append(("provider", "\(defaultValue.providerType).self"))
            }

            function = FunctionBuilder(
                name: "CustomCodingDecoding.decode",
                parameters: parameters
            )
        } else {
            /*
             // keyed
             func decode(_ type: String.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> String

             // single
             func decode(_ type: String.Type) throws -> String
             */
            var parameters: FunctionBuilder.Params = [
                (nil, type.typeDescription(preservingOptional: false)),
            ]

            let name: String
            switch strategy {
            case .singleValue:
                function = FunctionBuilder(
                    name: "container.decode",
                    parameters: parameters,
                    isOptionalTry: type.isOptional
                )
            case .codingKeys:
                name = type.isOptional ? "container.decodeIfPresent" : "container.decode"
                parameters.append(("forKey", ".\(identifier)"))

                function = FunctionBuilder(
                    name: name,
                    parameters: parameters
                )
            }
        }

        return DecodableBuilder.BuildingData.Item(identifier: identifier, function: function.build())
    }
}
