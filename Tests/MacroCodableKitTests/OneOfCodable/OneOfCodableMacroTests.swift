//
//  OneOfCodableMacroTests.swift
//
//
//  Created by Mikhail Maslo on 07.10.23.
//

import Macro
import MacroTesting
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

private let isRecording = false

final class OneOfCodableMacroTests: XCTestCase {
    func test() {
        withMacroTesting(
            isRecording: isRecording,
            macros: [
                "OneOfCodable": OneOfCodableMacro.self,
            ]
        ) {
            assertMacro {
                """
                @OneOfCodable
                struct NoApplicable\(sutSuffix) {}
                """
            } diagnostics: {
                """
                @OneOfCodable
                ╰─ 🛑 '@OneOfCodable' macro can only be applied to a enum
                struct NoApplicable__testing__ {}
                """
            }

            assertMacro {
                """
                @OneOfCodable
                class NoApplicable\(sutSuffix) {}
                """
            } diagnostics: {
                """
                @OneOfCodable
                ╰─ 🛑 '@OneOfCodable' macro can only be applied to a enum
                class NoApplicable__testing__ {}
                """
            }

            assertMacro {
                """
                @OneOfCodable
                enum Applicable\(sutSuffix) {
                    case int(Int)
                    case optionalInt(Int?)
                    case withLabel(label: Int)
                    case optionalWithLabel(label: Int?)
                    case withUnderscoredLabel(_ label: Int)
                    case optionalWithUnderscoredLabel(_ label: Int?)
                }
                """
            } expansion: {
                """
                enum Applicable__testing__ {
                    case int(Int)
                    case optionalInt(Int?)
                    case withLabel(label: Int)
                    case optionalWithLabel(label: Int?)
                    case withUnderscoredLabel(_ label: Int)
                    case optionalWithUnderscoredLabel(_ label: Int?)
                }

                extension Applicable__testing__: Decodable, Encodable {
                    enum CodingKeys: String, CodingKey {
                        case int
                        case optionalInt
                        case withLabel
                        case optionalWithLabel
                        case withUnderscoredLabel
                        case optionalWithUnderscoredLabel
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        guard let key = container.allKeys.first else {
                            throw DecodingError.dataCorrupted(
                                .init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case.")
                            )
                        }
                        switch key {
                        case .int:
                            self = .int(try container.decode(Int.self, forKey: key))
                        case .optionalInt:
                            self = .optionalInt(try container.decodeIfPresent(Int.self, forKey: key))
                        case .withLabel:
                            self = .withLabel(label: try container.decode(Int.self, forKey: key))
                        case .optionalWithLabel:
                            self = .optionalWithLabel(label: try container.decodeIfPresent(Int.self, forKey: key))
                        case .withUnderscoredLabel:
                            self = .withUnderscoredLabel(try container.decode(Int.self, forKey: key))
                        case .optionalWithUnderscoredLabel:
                            self = .optionalWithUnderscoredLabel(try container.decodeIfPresent(Int.self, forKey: key))
                        }
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        switch self {
                        case .int(let payload):
                            try container.encode(payload, forKey: .int)
                        case .optionalInt(let payload):
                            try container.encodeIfPresent(payload, forKey: .optionalInt)
                        case .withLabel(let payload):
                            try container.encode(payload, forKey: .withLabel)
                        case .optionalWithLabel(let payload):
                            try container.encodeIfPresent(payload, forKey: .optionalWithLabel)
                        case .withUnderscoredLabel(let payload):
                            try container.encode(payload, forKey: .withUnderscoredLabel)
                        case .optionalWithUnderscoredLabel(let payload):
                            try container.encodeIfPresent(payload, forKey: .optionalWithUnderscoredLabel)
                        }
                    }
                }
                """
            }

            assertMacro {
                """
                @OneOfCodable
                enum NoCodableExample\(sutSuffix) {
                    case int(Int)
                }

                @OneOfCodable
                enum OnlyEncodableExample\(sutSuffix): Encodable {
                    case int(Int)
                }

                @OneOfCodable
                enum OnlyDecodableExample\(sutSuffix): Decodable {
                    case int(Int)
                }

                @OneOfCodable
                enum EncodableAndCodableExample\(sutSuffix): Encodable, Decodable {
                    case int(Int)
                }

                @OneOfCodable
                enum CodableExample\(sutSuffix): Codable {
                    case int(Int)
                }
                """
            } diagnostics: {
                """
                @OneOfCodable
                enum NoCodableExample__testing__ {
                    case int(Int)
                }

                @OneOfCodable
                ╰─ ⚠️ '@OneOfCodable' macro won't generate 'Encodable' conformance since 'OnlyEncodableExample__testing__' already conformes to it. Consider using '@OneOfDecodable' instead
                enum OnlyEncodableExample__testing__: Encodable {
                    case int(Int)
                }

                @OneOfCodable
                ╰─ ⚠️ '@OneOfCodable' macro won't generate 'Decodable' conformance since 'OnlyDecodableExample__testing__' already conformes to it. Consider using '@OneOfEncodable' instead
                enum OnlyDecodableExample__testing__: Decodable {
                    case int(Int)
                }

                @OneOfCodable
                ╰─ ⚠️ '@OneOfCodable' macro has not effect since 'EncodableAndCodableExample__testing__' already conformes to ["Decodable", "Encodable"]. Consider removing '@OneOfCodable'
                enum EncodableAndCodableExample__testing__: Encodable, Decodable {
                    case int(Int)
                }

                @OneOfCodable
                ╰─ ⚠️ '@OneOfCodable' macro has not effect since 'CodableExample__testing__' already conformes to ["Decodable", "Encodable"]. Consider removing '@OneOfCodable'
                enum CodableExample__testing__: Codable {
                    case int(Int)
                }
                """
            } expansion: {
                """
                enum NoCodableExample__testing__ {
                    case int(Int)
                }
                enum OnlyEncodableExample__testing__: Encodable {
                    case int(Int)
                }
                enum OnlyDecodableExample__testing__: Decodable {
                    case int(Int)
                }
                enum EncodableAndCodableExample__testing__: Encodable, Decodable {
                    case int(Int)
                }
                enum CodableExample__testing__: Codable {
                    case int(Int)
                }

                extension NoCodableExample__testing__: Decodable, Encodable {
                    enum CodingKeys: String, CodingKey {
                        case int
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        guard let key = container.allKeys.first else {
                            throw DecodingError.dataCorrupted(
                                .init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case.")
                            )
                        }
                        switch key {
                        case .int:
                            self = .int(try container.decode(Int.self, forKey: key))
                        }
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        switch self {
                        case .int(let payload):
                            try container.encode(payload, forKey: .int)
                        }
                    }
                }

                extension OnlyEncodableExample__testing__: Decodable {
                    enum CodingKeys: String, CodingKey {
                        case int
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        guard let key = container.allKeys.first else {
                            throw DecodingError.dataCorrupted(
                                .init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case.")
                            )
                        }
                        switch key {
                        case .int:
                            self = .int(try container.decode(Int.self, forKey: key))
                        }
                    }
                }

                extension OnlyDecodableExample__testing__: Encodable {
                    enum CodingKeys: String, CodingKey {
                        case int
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        switch self {
                        case .int(let payload):
                            try container.encode(payload, forKey: .int)
                        }
                    }
                }
                """
            }

            assertMacro {
                """
                @OneOfCodable
                enum Empty\(sutSuffix) {}
                """
            } expansion: {
                """
                enum Empty__testing__ {}

                extension Empty__testing__: Decodable, Encodable {
                    init(from decoder: Decoder) throws {
                    }
                    func encode(to encoder: Encoder) throws {
                    }
                }
                """
            }

            assertMacro {
                """
                @OneOfCodable
                enum NoPublicCodable1\(sutSuffix) {
                    case int(Int)
                }

                @OneOfCodable
                private enum NoPublicCodable2\(sutSuffix) {
                    case int(Int)
                }

                @OneOfCodable
                internal enum NoPublicCodable3\(sutSuffix) {
                    case int(Int)
                }

                @OneOfCodable
                internal enum PublicCodable1\(sutSuffix) {
                    case int(Int)
                }
                """
            } expansion: {
                """
                enum NoPublicCodable1__testing__ {
                    case int(Int)
                }
                private enum NoPublicCodable2__testing__ {
                    case int(Int)
                }
                internal enum NoPublicCodable3__testing__ {
                    case int(Int)
                }
                internal enum PublicCodable1__testing__ {
                    case int(Int)
                }

                extension NoPublicCodable1__testing__: Decodable, Encodable {
                    enum CodingKeys: String, CodingKey {
                        case int
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        guard let key = container.allKeys.first else {
                            throw DecodingError.dataCorrupted(
                                .init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case.")
                            )
                        }
                        switch key {
                        case .int:
                            self = .int(try container.decode(Int.self, forKey: key))
                        }
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        switch self {
                        case .int(let payload):
                            try container.encode(payload, forKey: .int)
                        }
                    }
                }

                extension NoPublicCodable2__testing__: Decodable, Encodable {
                    enum CodingKeys: String, CodingKey {
                        case int
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        guard let key = container.allKeys.first else {
                            throw DecodingError.dataCorrupted(
                                .init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case.")
                            )
                        }
                        switch key {
                        case .int:
                            self = .int(try container.decode(Int.self, forKey: key))
                        }
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        switch self {
                        case .int(let payload):
                            try container.encode(payload, forKey: .int)
                        }
                    }
                }

                extension NoPublicCodable3__testing__: Decodable, Encodable {
                    enum CodingKeys: String, CodingKey {
                        case int
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        guard let key = container.allKeys.first else {
                            throw DecodingError.dataCorrupted(
                                .init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case.")
                            )
                        }
                        switch key {
                        case .int:
                            self = .int(try container.decode(Int.self, forKey: key))
                        }
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        switch self {
                        case .int(let payload):
                            try container.encode(payload, forKey: .int)
                        }
                    }
                }

                extension PublicCodable1__testing__: Decodable, Encodable {
                    enum CodingKeys: String, CodingKey {
                        case int
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        guard let key = container.allKeys.first else {
                            throw DecodingError.dataCorrupted(
                                .init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case.")
                            )
                        }
                        switch key {
                        case .int:
                            self = .int(try container.decode(Int.self, forKey: key))
                        }
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        switch self {
                        case .int(let payload):
                            try container.encode(payload, forKey: .int)
                        }
                    }
                }
                """
            }
        }
    }

    func test_diagnostic() {
        withMacroTesting(
            isRecording: isRecording,
            macros: [
                "OneOfCodable": OneOfCodableMacro.self,
            ]
        ) {
            assertMacro {
                """
                @OneOfCodable
                enum Example\(sutSuffix) {
                    case a
                }
                """
            } diagnostics: {
                """
                @OneOfCodable
                enum Example__testing__ {
                    case a
                         ┬
                         ╰─ 🛑 '@OneOfCodable' macro requires each case to have one associated value
                }
                """
            }

            assertMacro {
                """
                @OneOfCodable
                enum Example\(sutSuffix) {
                    case a(Int, Int)
                }
                """
            } diagnostics: {
                """
                @OneOfCodable
                enum Example__testing__ {
                    case a(Int, Int)
                         ┬──────────
                         ╰─ 🛑 '@OneOfCodable' macro requires each case to have one associated value
                }
                """
            }
        }
    }
}
