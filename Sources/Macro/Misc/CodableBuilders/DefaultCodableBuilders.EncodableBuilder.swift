//
//  DefaultCodableBuilders.EncodableBuilder.swift
//
//
//  Created by Mikhail Maslo on 07.10.23.
//

import MacroToolkit

extension DefaultCodableBuilders {
    struct EncodableBuilder: CodeBuildable {
        private let accessModifier: AccessModifier?
        private let strategy: CodableStrategy
        private let members: [Decl]

        init(accessModifier: AccessModifier? = nil, strategy: CodableStrategy, members: [Decl]) {
            self.accessModifier = accessModifier
            self.strategy = strategy
            self.members = members
        }

        func build() -> String {
            let encodingImpl = members
                .flatMap { member -> [String] in
                    guard let variable = member.asVariable, !variable.isStatic else {
                        return []
                    }

                    return encodingLine(variable: variable)
                }

            return DeclarationBuilder(accessModifier: accessModifier, signature: "func encode(to encoder: Encoder) throws") {
                if encodingImpl.isEmpty {
                    ""
                } else {
                    switch strategy {
                    case .singleValue:
                        ""
                    case .codingKeys:
                        "var container = encoder.container(keyedBy: CodingKeys.self)"
                    }

                    encodingImpl
                }
            }.build()
        }

        private func encodingLine(variable: Variable) -> [String] {
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
                     ) throws
                     */
                    codingFunc = ThrowingFunc(
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
                    var parameters: ThrowingFunc.Params = [
                        (nil, "self.\(identifier)"),
                        ("forKey", ".\(identifier)"),
                        ("container", "&container"),
                    ]

                    if let strategy = knownAttributes[.valueStrategy]?.first as? ValueStrategy {
                        parameters.append(("strategy", "\(strategy.strategyType).self"))
                    }

                    codingFunc = ThrowingFunc(
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
                        codingFunc = ThrowingFunc(
                            name: bindingType.isOptional ? "self.\(identifier).encodeIfPresent" : "self.\(identifier).encode",
                            parameters: [
                                ("to", "encoder"),
                            ]
                        )
                    case .codingKeys:
                        codingFunc = ThrowingFunc(
                            name: bindingType.isOptional ? "container.encodeIfPresent" : "container.encode",
                            parameters: [
                                (nil, "self.\(identifier)"),
                                ("forKey", ".\(identifier)"),
                            ]
                        )
                    }
                }

                return codingFunc.build()
            }
        }
    }
}
