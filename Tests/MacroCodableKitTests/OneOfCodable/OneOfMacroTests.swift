//
//  OneOfMacroTests.swift
//
//
//  Created by Mikhail Maslo on 23.09.23.
//

import Macro
import MacroTesting
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

private let isRecording = false

final class OneOfMacroTests: XCTestCase {
    func test_Codable() {
        withMacroTesting(
            isRecording: isRecording,
            macros: [
                "OneOfCodable": OneOfCodableMacro.self,
            ]
        ) {
            assertMacro {
                """
                @OneOfCodable
                struct A {}
                """
            } diagnostics: {
                """
                @OneOfCodable
                ┬────────────
                ╰─ 🛑 'OneOfCodable' macro can only be applied to a enm
                struct A {}
                """
            }

            assertMacro {
                """
                @OneOfCodable
                enum A: Encodable {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }
                """
            } expansion: {
                """
                enum A: Encodable {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }

                extension A: Decodable {
                    enum CodingKeys: String, CodingKey {
                        case int
                        case boolean
                        case string
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
                        case .boolean:
                            self = .boolean(try container.decode(Bool.self, forKey: key))
                        case .string:
                            self = .string(try container.decode(String.self, forKey: key))
                        }
                    }
                }
                """
            }

            assertMacro {
                """
                @OneOfCodable
                enum A: Decodable {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }
                """
            } expansion: {
                """
                enum A: Decodable {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }

                extension A: Encodable {
                    enum CodingKeys: String, CodingKey {
                        case int
                        case boolean
                        case string
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        switch self {
                        case .int(let payload):
                            try container.encode(payload, forKey: .int)
                        case .boolean(let payload):
                            try container.encode(payload, forKey: .boolean)
                        case .string(let payload):
                            try container.encode(payload, forKey: .string)
                        }
                    }
                }
                """
            }

            assertMacro {
                """
                @OneOfCodable
                enum A: Codable {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }
                """
            } expansion: {
                """
                enum A: Codable {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }
                """
            }

            assertMacro {
                """
                @OneOfCodable
                enum A: Encodable, Decodable {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }
                """
            } expansion: {
                """
                enum A: Encodable, Decodable {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }
                """
            }

            assertMacro {
                """
                @OneOfCodable
                private enum A {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }
                """
            } expansion: {
                """
                private enum A {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }

                extension A: Decodable, Encodable {
                    enum CodingKeys: String, CodingKey {
                        case int
                        case boolean
                        case string
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
                        case .boolean:
                            self = .boolean(try container.decode(Bool.self, forKey: key))
                        case .string:
                            self = .string(try container.decode(String.self, forKey: key))
                        }
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        switch self {
                        case .int(let payload):
                            try container.encode(payload, forKey: .int)
                        case .boolean(let payload):
                            try container.encode(payload, forKey: .boolean)
                        case .string(let payload):
                            try container.encode(payload, forKey: .string)
                        }
                    }
                }
                """
            }

            assertMacro {
                """
                @OneOfCodable
                public enum A {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }
                """
            } expansion: {
                """
                public enum A {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }

                extension A: Decodable, Encodable {
                    public enum CodingKeys: String, CodingKey {
                        case int
                        case boolean
                        case string
                    }
                    public init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        guard let key = container.allKeys.first else {
                            throw DecodingError.dataCorrupted(
                                .init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case.")
                            )
                        }
                        switch key {
                        case .int:
                            self = .int(try container.decode(Int.self, forKey: key))
                        case .boolean:
                            self = .boolean(try container.decode(Bool.self, forKey: key))
                        case .string:
                            self = .string(try container.decode(String.self, forKey: key))
                        }
                    }
                    public func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        switch self {
                        case .int(let payload):
                            try container.encode(payload, forKey: .int)
                        case .boolean(let payload):
                            try container.encode(payload, forKey: .boolean)
                        case .string(let payload):
                            try container.encode(payload, forKey: .string)
                        }
                    }
                }
                """
            }
        }
    }

    func test_Decodable() {
        withMacroTesting(
            isRecording: isRecording,
            macros: [
                "OneOfDecodable": OneOfDecodableMacro.self,
            ]
        ) {
            assertMacro {
                """
                @OneOfDecodable
                struct A {}
                """
            } diagnostics: {
                """
                @OneOfDecodable
                ┬──────────────
                ╰─ 🛑 'OneOfDecodable' macro can only be applied to a enm
                struct A {}
                """
            }

            assertMacro {
                """
                @OneOfDecodable
                enum A: Encodable {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }
                """
            } expansion: {
                """
                enum A: Encodable {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }

                extension A: Decodable {
                    enum CodingKeys: String, CodingKey {
                        case int
                        case boolean
                        case string
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
                        case .boolean:
                            self = .boolean(try container.decode(Bool.self, forKey: key))
                        case .string:
                            self = .string(try container.decode(String.self, forKey: key))
                        }
                    }
                }
                """
            }

            assertMacro {
                """
                @OneOfDecodable
                enum A: Decodable {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }
                """
            } expansion: {
                """
                enum A: Decodable {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }
                """
            }

            assertMacro {
                """
                @OneOfDecodable
                enum A: Codable {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }
                """
            } expansion: {
                """
                enum A: Codable {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }
                """
            }

            assertMacro {
                """
                @OneOfDecodable
                enum A: Encodable, Decodable {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }
                """
            } expansion: {
                """
                enum A: Encodable, Decodable {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }
                """
            }

            assertMacro {
                """
                @OneOfDecodable
                private enum A {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }
                """
            } expansion: {
                """
                private enum A {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }

                extension A: Decodable {
                    enum CodingKeys: String, CodingKey {
                        case int
                        case boolean
                        case string
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
                        case .boolean:
                            self = .boolean(try container.decode(Bool.self, forKey: key))
                        case .string:
                            self = .string(try container.decode(String.self, forKey: key))
                        }
                    }
                }
                """
            }

            assertMacro {
                """
                @OneOfDecodable
                public enum A {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }
                """
            } expansion: {
                """
                public enum A {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }

                extension A: Decodable {
                    public enum CodingKeys: String, CodingKey {
                        case int
                        case boolean
                        case string
                    }
                    public init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        guard let key = container.allKeys.first else {
                            throw DecodingError.dataCorrupted(
                                .init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case.")
                            )
                        }
                        switch key {
                        case .int:
                            self = .int(try container.decode(Int.self, forKey: key))
                        case .boolean:
                            self = .boolean(try container.decode(Bool.self, forKey: key))
                        case .string:
                            self = .string(try container.decode(String.self, forKey: key))
                        }
                    }
                }
                """
            }
        }
    }

    func test_Encodable() {
        withMacroTesting(
            isRecording: isRecording,
            macros: [
                "OneOfEncodable": OneOfEncodableMacro.self,
            ]
        ) {
            assertMacro {
                """
                @OneOfEncodable
                struct A {}
                """
            } diagnostics: {
                """
                @OneOfEncodable
                ┬──────────────
                ╰─ 🛑 'OneOfEncodable' macro can only be applied to a enm
                struct A {}
                """
            }

            assertMacro {
                """
                @OneOfEncodable
                enum A: Encodable {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }
                """
            } expansion: {
                """
                enum A: Encodable {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }
                """
            }

            assertMacro {
                """
                @OneOfEncodable
                enum A: Decodable {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }
                """
            } expansion: {
                """
                enum A: Decodable {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }

                extension A: Encodable {
                    enum CodingKeys: String, CodingKey {
                        case int
                        case boolean
                        case string
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        switch self {
                        case .int(let payload):
                            try container.encode(payload, forKey: .int)
                        case .boolean(let payload):
                            try container.encode(payload, forKey: .boolean)
                        case .string(let payload):
                            try container.encode(payload, forKey: .string)
                        }
                    }
                }
                """
            }

            assertMacro {
                """
                @OneOfEncodable
                enum A: Codable {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }
                """
            } expansion: {
                """
                enum A: Codable {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }
                """
            }

            assertMacro {
                """
                @OneOfEncodable
                enum A: Encodable, Decodable {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }
                """
            } expansion: {
                """
                enum A: Encodable, Decodable {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }
                """
            }

            assertMacro {
                """
                @OneOfEncodable
                private enum A {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }
                """
            } expansion: {
                """
                private enum A {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }

                extension A: Encodable {
                    enum CodingKeys: String, CodingKey {
                        case int
                        case boolean
                        case string
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        switch self {
                        case .int(let payload):
                            try container.encode(payload, forKey: .int)
                        case .boolean(let payload):
                            try container.encode(payload, forKey: .boolean)
                        case .string(let payload):
                            try container.encode(payload, forKey: .string)
                        }
                    }
                }
                """
            }

            assertMacro {
                """
                @OneOfEncodable
                public enum A {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }
                """
            } expansion: {
                """
                public enum A {
                    case int(Int)
                    case boolean(Bool)
                    case string(String)
                }

                extension A: Encodable {
                    public enum CodingKeys: String, CodingKey {
                        case int
                        case boolean
                        case string
                    }
                    public func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        switch self {
                        case .int(let payload):
                            try container.encode(payload, forKey: .int)
                        case .boolean(let payload):
                            try container.encode(payload, forKey: .boolean)
                        case .string(let payload):
                            try container.encode(payload, forKey: .string)
                        }
                    }
                }
                """
            }
        }
    }
}
