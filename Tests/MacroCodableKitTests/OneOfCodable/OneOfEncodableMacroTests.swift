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
                struct NoApplicable {}
                """
            } diagnostics: {
                """
                @OneOfEncodable
                ╰─ 🛑 '@OneOfEncodable' macro can only be applied to a enum
                struct NoApplicable {}
                """
            }

            assertMacro {
                """
                @OneOfEncodable
                class NoApplicable {}
                """
            } diagnostics: {
                """
                @OneOfEncodable
                ╰─ 🛑 '@OneOfEncodable' macro can only be applied to a enum
                class NoApplicable {}
                """
            }

            assertMacro {
                """
                @OneOfEncodable
                enum Applicable {
                    case int(Int)
                    case optionalInt(Int?)
                }
                """
            } expansion: {
                """
                enum Applicable {
                    case int(Int)
                    case optionalInt(Int?)
                }

                extension Applicable: Encodable {
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
                enum NoCodableExample: Encodable {
                    case int(Int)
                }

                @OneOfEncodable
                enum OnlyEncodableExample: Encodable {
                    case int(Int)
                }

                @OneOfEncodable
                enum OnlyDecodableExample: Decodable {
                    case int(Int)
                }

                @OneOfEncodable
                enum EncodableAndCodableExample: Encodable, Decodable {
                    case int(Int)
                }

                @OneOfEncodable
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
                @OneOfEncodable
                enum Empty {}
                """
            } expansion: {
                """
                enum Empty {}

                extension Empty: Encodable {
                    func encode(to encoder: Encoder) throws {
                    }
                }
                """
            }

            assertMacro {
                """
                @OneOfEncodable
                enum NoPublicCodable1 {
                    case int(Int)
                }

                @OneOfEncodable
                private enum NoPublicCodable2 {
                    case int(Int)
                }

                @OneOfEncodable
                internal enum NoPublicCodable3 {
                    case int(Int)
                }

                @OneOfEncodable
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

                extension NoPublicCodable1: Encodable {
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

                extension NoPublicCodable2: Encodable {
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

                extension NoPublicCodable3: Encodable {
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

                extension PublicCodable1: Encodable {
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
