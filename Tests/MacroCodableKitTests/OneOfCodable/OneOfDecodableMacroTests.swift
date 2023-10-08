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
                struct NoApplicable\(sutSuffix) {}
                """
            } diagnostics: {
                """
                @OneOfDecodable
                ╰─ 🛑 '@OneOfDecodable' macro can only be applied to a enum
                struct NoApplicable__testing__ {}
                """
            }

            assertMacro {
                """
                @OneOfDecodable
                class NoApplicable\(sutSuffix) {}
                """
            } diagnostics: {
                """
                @OneOfDecodable
                ╰─ 🛑 '@OneOfDecodable' macro can only be applied to a enum
                class NoApplicable__testing__ {}
                """
            }

            assertMacro {
                """
                @OneOfDecodable
                enum Applicable\(sutSuffix) {
                    case int(Int)
                    case optionalInt(Int?)
                }
                """
            } expansion: {
                """
                enum Applicable__testing__ {
                    case int(Int)
                    case optionalInt(Int?)
                }

                extension Applicable__testing__: Decodable {
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
                enum NoCodableExample\(sutSuffix) {
                    case int(Int)
                }

                @OneOfDecodable
                enum OnlyEncodableExample\(sutSuffix): Encodable {
                    case int(Int)
                }

                @OneOfDecodable
                enum OnlyDecodableExample\(sutSuffix): Decodable {
                    case int(Int)
                }

                @OneOfDecodable
                enum EncodableAndCodableExample\(sutSuffix): Encodable, Decodable {
                    case int(Int)
                }

                @OneOfDecodable
                enum CodableExample\(sutSuffix): Codable {
                    case int(Int)
                }
                """
            } diagnostics: {
                """
                @OneOfDecodable
                enum NoCodableExample__testing__ {
                    case int(Int)
                }

                @OneOfDecodable
                enum OnlyEncodableExample__testing__: Encodable {
                    case int(Int)
                }

                @OneOfDecodable
                ╰─ ⚠️ '@OneOfDecodable' macro has not effect since 'OnlyDecodableExample__testing__' already conformes to ["Decodable"]. Consider removing '@OneOfDecodable'
                enum OnlyDecodableExample__testing__: Decodable {
                    case int(Int)
                }

                @OneOfDecodable
                ╰─ ⚠️ '@OneOfDecodable' macro has not effect since 'EncodableAndCodableExample__testing__' already conformes to ["Decodable"]. Consider removing '@OneOfDecodable'
                enum EncodableAndCodableExample__testing__: Encodable, Decodable {
                    case int(Int)
                }

                @OneOfDecodable
                ╰─ ⚠️ '@OneOfDecodable' macro has not effect since 'CodableExample__testing__' already conformes to ["Decodable"]. Consider removing '@OneOfDecodable'
                enum CodableExample__testing__: Codable {
                    case int(Int)
                }
                """
            }expansion: {
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

                extension NoCodableExample__testing__: Decodable {
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
                """
            }

            assertMacro {
                """
                @OneOfDecodable
                enum Empty\(sutSuffix) {}
                """
            } expansion: {
                """
                enum Empty__testing__ {}

                extension Empty__testing__: Decodable {
                    init(from decoder: Decoder) throws {
                    }
                }
                """
            }

            assertMacro {
                """
                @OneOfDecodable
                enum NoPublicCodable1\(sutSuffix) {
                    case int(Int)
                }

                @OneOfDecodable
                private enum NoPublicCodable2\(sutSuffix) {
                    case int(Int)
                }

                @OneOfDecodable
                internal enum NoPublicCodable3\(sutSuffix) {
                    case int(Int)
                }

                @OneOfDecodable
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

                extension NoPublicCodable1__testing__: Decodable {
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

                extension NoPublicCodable2__testing__: Decodable {
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

                extension NoPublicCodable3__testing__: Decodable {
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

                extension PublicCodable1__testing__: Decodable {
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
