//
//  OneOfDecodableMacroTests.swift
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

final class OneOfDecodableMacroTests: XCTestCase {
    func test() {
        withMacroTesting(
            isRecording: isRecording,
            macros: [
                "OneOfDecodable": OneOfDecodableMacro.self,
            ]
        ) {
            assertMacro {
                """
                @OneOfDecodable
                struct NoApplicable {}
                """
            } diagnostics: {
                """
                @OneOfDecodable
                ╰─ 🛑 '@OneOfDecodable' macro can only be applied to a enum
                struct NoApplicable {}
                """
            }

            assertMacro {
                """
                @OneOfDecodable
                class NoApplicable {}
                """
            } diagnostics: {
                """
                @OneOfDecodable
                ╰─ 🛑 '@OneOfDecodable' macro can only be applied to a enum
                class NoApplicable {}
                """
            }

            assertMacro {
                """
                @OneOfDecodable
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

                extension Applicable: Decodable {
                    enum CodingKeys: String, CodingKey {
                        case int
                        case optionalInt
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
                        }
                    }
                }
                """
            }

            assertMacro {
                """
                @OneOfDecodable
                enum NoCodableExample: Encodable {
                    case int(Int)
                }

                @OneOfDecodable
                enum OnlyEncodableExample: Encodable {
                    case int(Int)
                }

                @OneOfDecodable
                enum OnlyDecodableExample: Decodable {
                    case int(Int)
                }

                @OneOfDecodable
                enum EncodableAndCodableExample: Encodable, Decodable {
                    case int(Int)
                }

                @OneOfDecodable
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
                """
            }

            assertMacro {
                """
                @OneOfDecodable
                enum Empty {}
                """
            } expansion: {
                """
                enum Empty {}

                extension Empty: Decodable {
                    init(from decoder: Decoder) throws {
                    }
                }
                """
            }

            assertMacro {
                """
                @OneOfDecodable
                enum NoPublicCodable1 {
                    case int(Int)
                }

                @OneOfDecodable
                private enum NoPublicCodable2 {
                    case int(Int)
                }

                @OneOfDecodable
                internal enum NoPublicCodable3 {
                    case int(Int)
                }

                @OneOfDecodable
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

                extension NoPublicCodable1: Decodable {
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

                extension NoPublicCodable2: Decodable {
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

                extension NoPublicCodable3: Decodable {
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

                extension PublicCodable1: Decodable {
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
                """
            }
        }
    }
}
