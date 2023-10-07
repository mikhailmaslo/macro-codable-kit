//
//  DefaultCodableBuilders.DecodableBuilder.swift
//
//
//  Created by Mikhail Maslo on 07.10.23.
//

import MacroToolkit

extension DefaultCodableBuilders {
    struct DecodableBuilder: CodeBuildable {
        private let accessModifier: AccessModifier?
        private let strategy: CodableStrategy
        private let members: [Decl]

        init(accessModifier: AccessModifier? = nil, strategy: CodableStrategy, members: [Decl]) {
            self.accessModifier = accessModifier
            self.strategy = strategy
            self.members = members
        }

        func build() -> String {
            let decodingImpl = members
                .flatMap { member in
                    guard let variable = member.asVariable, !variable.isStatic else {
                        return [String]()
                    }

                    return decodingLine(variable: variable)
                }

            return DeclarationBuilder(accessModifier: accessModifier, signature: "init(from decoder: Decoder) throws") {
                if decodingImpl.isEmpty {
                    ""
                } else {
                    switch strategy {
                    case .singleValue:
                        "let container = try decoder.singleValueContainer()"
                    case .codingKeys:
                        "let container = try decoder.container(keyedBy: CodingKeys.self)"
                    }

                    decodingImpl
                }
            }.build()
        }

        private func decodingLine(variable: Variable) -> [String] {
            let knownAttributes = variable.knownAttributes()
            guard knownAttributes[.omitCoding] == nil else { return [] }
            guard variable.isStoredProperty else { return [] }

            return variable.bindings.compactMap { binding -> String? in
                guard
                    let identifier = binding.identifier,
                    let bindingType = binding.type
                else {
                    return nil
                }

                func typeDescription(preservingOptional: Bool) -> String {
                    var result: String
                    switch bindingType {
                    case let .optional(optionalType):
                        result = preservingOptional ? optionalType._baseSyntax.trimmedDescription : optionalType._baseSyntax.wrappedType.trimmedDescription
                    default:
                        result = bindingType._baseSyntax.trimmedDescription
                    }
                    return "\(result).self"
                }

                let codingFunc: ThrowingFunc
                if let customCoding = knownAttributes[.customCoding]?.first as? CustomCoding {
                    /*
                     static func \(customCoding.codingNameType)<K, Element: Decodable>(
                     _: [Element].Type,
                     forKey key: KeyedDecodingContainer<K>.Key,
                     container: KeyedDecodingContainer<K>
                     ) throws -> [Element]
                     */
                    codingFunc = ThrowingFunc(
                        name: "CustomCodingDecoding.\(customCoding.codingNameType.lowercasingFirstLetter())",
                        parameters: [
                            (nil, typeDescription(preservingOptional: true)),
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
                    var parameters: ThrowingFunc.Params = [
                        (nil, typeDescription(preservingOptional: true)),
                        ("forKey", ".\(identifier)"),
                        ("container", "container"),
                    ]

                    if let strategy = knownAttributes[.valueStrategy]?.first as? ValueStrategy {
                        parameters.append(("strategy", "\(strategy.strategyType).self"))
                    }

                    if let defaultValue = knownAttributes[.defaultValue]?.first as? DefaultValue {
                        parameters.append(("provider", "\(defaultValue.providerType).self"))
                    }

                    codingFunc = ThrowingFunc(
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
                    var parameters: ThrowingFunc.Params = [
                        (nil, typeDescription(preservingOptional: false)),
                    ]

                    switch strategy {
                    case .singleValue:
                        break
                    case .codingKeys:
                        parameters.append(("forKey", ".\(identifier)"))
                    }

                    codingFunc = ThrowingFunc(
                        name: bindingType.isOptional ? "container.decodeIfPresent" : "container.decode",
                        parameters: parameters
                    )
                }

                return "self.\(identifier) = \(codingFunc.build())"
            }
        }
    }
}
