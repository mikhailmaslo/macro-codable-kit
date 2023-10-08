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
                struct NoApplicable {}
                """
            } diagnostics: {
                """
                @OneOfCodable
                ╰─ 🛑 '@OneOfCodable' macro can only be applied to a enum
                struct NoApplicable {}
                """
            }

            assertMacro {
                """
                @OneOfCodable
                class NoApplicable {}
                """
            } diagnostics: {
                """
                @OneOfCodable
                ╰─ 🛑 '@OneOfCodable' macro can only be applied to a enum
                class NoApplicable {}
                """
            }

            assertMacro {
                """
                @OneOfCodable
                enum Applicable {
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
                enum Applicable {
                    case int(Int)
                    case optionalInt(Int?)
                    case withLabel(label: Int)
                    case optionalWithLabel(label: Int?)
                    case withUnderscoredLabel(_ label: Int)
                    case optionalWithUnderscoredLabel(_ label: Int?)
                }

                extension Applicable: Decodable, Encodable {
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
                enum NoCodableExample: Encodable {
                    case int(Int)
                }

                @OneOfCodable
                enum OnlyEncodableExample: Encodable {
                    case int(Int)
                }

                @OneOfCodable
                enum OnlyDecodableExample: Decodable {
                    case int(Int)
                }

                @OneOfCodable
                enum EncodableAndCodableExample: Encodable, Decodable {
                    case int(Int)
                }

                @OneOfCodable
                enum CodableExample: Codable {
                    case int(Int)
                }
                """
            } expansion: {
                """
                enum NoCodableExample: Encodable {
                    case int(Int)
                }
                enum OnlyEncodableExample: Encodable {
                    case int(Int)
                }
                enum OnlyDecodableExample: Decodable {
                    case int(Int)
                }
                enum EncodableAndCodableExample: Encodable, Decodable {
                    case int(Int)
                }
                enum CodableExample: Codable {
                    case int(Int)
                }

                extension NoCodableExample: Decodable {
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

                extension OnlyEncodableExample: Decodable {
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

                extension OnlyDecodableExample: Encodable {
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
                enum Empty {}
                """
            } expansion: {
                """
                enum Empty {}

                extension Empty: Decodable, Encodable {
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
                enum NoPublicCodable1 {
                    case int(Int)
                }

                @OneOfCodable
                private enum NoPublicCodable2 {
                    case int(Int)
                }

                @OneOfCodable
                internal enum NoPublicCodable3 {
                    case int(Int)
                }

                @OneOfCodable
                internal enum PublicCodable1 {
                    case int(Int)
                }
                """
            } expansion: {
                """
                enum NoPublicCodable1 {
                    case int(Int)
                }
                private enum NoPublicCodable2 {
                    case int(Int)
                }
                internal enum NoPublicCodable3 {
                    case int(Int)
                }
                internal enum PublicCodable1 {
                    case int(Int)
                }

                extension NoPublicCodable1: Decodable, Encodable {
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

                extension NoPublicCodable2: Decodable, Encodable {
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

                extension NoPublicCodable3: Decodable, Encodable {
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

                extension PublicCodable1: Decodable, Encodable {
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
                enum Example {
                    case a
                }
                """
            } diagnostics: {
                """
                @OneOfCodable
                enum Example {
                    case a
                         ┬
                         ╰─ 🛑 '@OneOfCodable' macro requires each case to have one associated value
                }
                """
            }

            assertMacro {
                """
                @OneOfCodable
                enum Example {
                    case a(Int, Int)
                }
                """
            } diagnostics: {
                """
                @OneOfCodable
                enum Example {
                    case a(Int, Int)
                         ┬──────────
                         ╰─ 🛑 '@OneOfCodable' macro requires each case to have one associated value
                }
                """
            }
        }
    }
}
