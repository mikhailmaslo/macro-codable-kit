//
//  DefaultCodableBuilders.swift
//
//
//  Created by Mikhail Maslo on 25.09.23.
//

import MacroToolkit
import SwiftSyntax
import SwiftSyntaxBuilder

struct DefaultDecodableBuilder: CodeBuildable {
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

enum CodableStrategy {
    case singleValue
    case codingKeys
}

struct DefaultEncodableBuilder: CodeBuildable {
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

struct CodingKeysCodeBuilder: CodeBuildable {
    private let accessModifier: AccessModifier?
    private let keyValues: [(String, String?)]

    init(accessModifier: AccessModifier?, enumDecl: Enum) {
        self.accessModifier = accessModifier
        keyValues = enumDecl.cases.map { ($0.identifier, nil) }
    }

    init(accessModifier: AccessModifier?, members: [Decl]) {
        self.accessModifier = accessModifier
        keyValues = members
            .flatMap { member -> [(String, String?)] in
                guard let variable = member.asVariable, !variable.isStatic else {
                    return []
                }

                let knownAttributes = variable.knownAttributes()
                guard knownAttributes[.omitCoding] == nil else {
                    return []
                }

                return variable.bindings.compactMap { binding -> (String, String?)? in
                    guard let identifier = binding.identifier else { return nil }

                    return (identifier, (knownAttributes[.codingKey]?.first as? CodingKey)?.key)
                }
            }
    }

    func build() -> String {
        if keyValues.isEmpty {
            return ""
        } else {
            return DeclarationBuilder(accessModifier: accessModifier, signature: "enum CodingKeys: String, CodingKey") {
                keyValues.map { "case \($0.0)" + ($0.1.map { " = \"\($0)\"" } ?? "") }
            }.build()
        }
    }
}

enum KnownAttribute: String {
    case omitCoding
    case codingKey
    case defaultValue
    case valueStrategy
    case customCoding
}

extension Variable {
    func knownAttributes() -> [KnownAttribute: [Any]] {
        var result: [KnownAttribute: [Any]] = [:]
        result.reserveCapacity(attributes.count)
        for attribute in attributes {
            if let omitCoding = attribute.attribute.flatMap({ OmitCoding($0) }) {
                result[.omitCoding, default: []].append(omitCoding)
            } else if let codingKey = attribute.attribute.flatMap({ CodingKey($0) }) {
                result[.codingKey, default: []].append(codingKey)
            } else if let defaultValue = attribute.attribute.flatMap({ DefaultValue($0) }) {
                result[.defaultValue, default: []].append(defaultValue)
            } else if let valueStrategy = attribute.attribute.flatMap({ ValueStrategy($0) }) {
                result[.valueStrategy, default: []].append(valueStrategy)
            } else if let customCoding = attribute.attribute.flatMap({ CustomCoding($0) }) {
                result[.customCoding, default: []].append(customCoding)
            } else {
                // ignore unknown attributes
            }
        }
        return result
    }
}

struct ThrowingFunc: CodeBuildable {
    typealias Params = [(String?, String)]

    let name: String
    let parameters: Params

    func build() -> String {
        "try \(name)(\(parameters.map { ($0.0.map { "\($0): " } ?? "") + $0.1 }.joined(separator: ",")))"
    }
}
