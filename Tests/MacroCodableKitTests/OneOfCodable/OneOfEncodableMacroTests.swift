//
//  OneOfEncodableMacroTests.swift
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

final class OneOfEncodableMacroTests: XCTestCase {
    func test() {
        withMacroTesting(
            isRecording: isRecording,
            macros: [
                "OneOfEncodable": OneOfEncodableMacro.self,
            ]
        ) {
            assertMacro {
                """
                @OneOfEncodable
                struct NoApplicable\(sutSuffix) {}
                """
            } diagnostics: {
                """
                @OneOfEncodable
                ╰─ 🛑 '@OneOfEncodable' macro can only be applied to a enum
                struct NoApplicable__testing__ {}
                """
            }

            assertMacro {
                """
                @OneOfEncodable
                class NoApplicable\(sutSuffix) {}
                """
            } diagnostics: {
                """
                @OneOfEncodable
                ╰─ 🛑 '@OneOfEncodable' macro can only be applied to a enum
                class NoApplicable__testing__ {}
                """
            }

            assertMacro {
                """
                @OneOfEncodable
                enum Applicable\(sutSuffix) {
                    case int(Int)
                    case optionalInt(Int?)
                }
                """
            } diagnostics: {
                """

                """
            } expansion: {
                """
                enum Applicable__testing__ {
                    case int(Int)
                    case optionalInt(Int?)
                }

                extension Applicable__testing__: Encodable {
                    enum CodingKeys: String, CodingKey {
                        case int
                        case optionalInt
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        switch self {
                        case .int(let payload):
                            try container.encode(payload, forKey: .int)
                        case .optionalInt(let payload):
                            try container.encodeIfPresent(payload, forKey: .optionalInt)
                        }
                    }
                }
                """
            }

            assertMacro {
                """
                @OneOfEncodable
                enum NoCodableExample\(sutSuffix) {
                    case int(Int)
                }

                @OneOfEncodable
                enum OnlyEncodableExample\(sutSuffix): Encodable {
                    case int(Int)
                }

                @OneOfEncodable
                enum OnlyDecodableExample\(sutSuffix): Decodable {
                    case int(Int)
                }

                @OneOfEncodable
                enum EncodableAndCodableExample\(sutSuffix): Encodable, Decodable {
                    case int(Int)
                }

                @OneOfEncodable
                enum CodableExample\(sutSuffix): Codable {
                    case int(Int)
                }
                """
            } diagnostics: {
                """
                @OneOfEncodable
                enum NoCodableExample__testing__ {
                    case int(Int)
                }

                @OneOfEncodable
                ╰─ ⚠️ '@OneOfEncodable' macro has not effect since 'OnlyEncodableExample__testing__' already conformes to ["Encodable"]. Consider removing '@OneOfEncodable'
                enum OnlyEncodableExample__testing__: Encodable {
                    case int(Int)
                }

                @OneOfEncodable
                enum OnlyDecodableExample__testing__: Decodable {
                    case int(Int)
                }

                @OneOfEncodable
                ╰─ ⚠️ '@OneOfEncodable' macro has not effect since 'EncodableAndCodableExample__testing__' already conformes to ["Encodable"]. Consider removing '@OneOfEncodable'
                enum EncodableAndCodableExample__testing__: Encodable, Decodable {
                    case int(Int)
                }

                @OneOfEncodable
                ╰─ ⚠️ '@OneOfEncodable' macro has not effect since 'CodableExample__testing__' already conformes to ["Encodable"]. Consider removing '@OneOfEncodable'
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

                extension NoCodableExample__testing__: Encodable {
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
                @OneOfEncodable
                enum Empty\(sutSuffix) {}
                """
            } expansion: {
                """
                enum Empty__testing__ {}

                extension Empty__testing__: Encodable {
                    func encode(to encoder: Encoder) throws {
                    }
                }
                """
            }

            assertMacro {
                """
                @OneOfEncodable
                enum NoPublicCodable1\(sutSuffix) {
                    case int(Int)
                }

                @OneOfEncodable
                private enum NoPublicCodable2\(sutSuffix) {
                    case int(Int)
                }

                @OneOfEncodable
                internal enum NoPublicCodable3\(sutSuffix) {
                    case int(Int)
                }

                @OneOfEncodable
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

                extension NoPublicCodable1__testing__: Encodable {
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

                extension NoPublicCodable2__testing__: Encodable {
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

                extension NoPublicCodable3__testing__: Encodable {
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

                extension PublicCodable1__testing__: Encodable {
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
        }
    }
}
