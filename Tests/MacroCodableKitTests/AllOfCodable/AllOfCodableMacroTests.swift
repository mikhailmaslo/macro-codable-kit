//
//  AllOfCodableMacroTests.swift
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

final class AllOfCodableMacroTests: XCTestCase {
    func test() throws {
        withMacroTesting(
            isRecording: isRecording,
            macros: [
                "AllOfCodable": AllOfCodableMacro.self,
                "OmitCoding": OmitCodingMacro.self,
            ]
        ) {
            assertMacro {
                """
                @AllOfCodable
                enum NotApplicable {}
                """
            } diagnostics: {
                """
                @AllOfCodable
                ╰─ 🛑 'AllOfCodable' macro can only be applied to a struct
                enum NotApplicable {}
                """
            }

            assertMacro {
                """
                @AllOfCodable
                class NotApplicable {}
                """
            } diagnostics: {
                """
                @AllOfCodable
                ╰─ 🛑 'AllOfCodable' macro can only be applied to a struct
                class NotApplicable {}
                """
            }

            assertMacro {
                """
                @AllOfCodable
                struct Example {
                    let brand: Brand?
                    let company: Company
                    @OmitCoding
                    let omittedCompany: Company

                    var string: String { "" }
                }
                """
            } expansion: {
                """
                struct Example {
                    let brand: Brand?
                    let company: Company
                    let omittedCompany: Company

                    var string: String { "" }
                }

                extension Example: Decodable, Encodable {
                    init(from decoder: Decoder) throws {
                        let container = try decoder.singleValueContainer()
                        self.brand = try container.decodeIfPresent(Brand.self)
                        self.company = try container.decode(Company.self)
                    }
                    func encode(to encoder: Encoder) throws {
                        try self.brand.encodeIfPresent(to: encoder)
                        try self.company.encode(to: encoder)
                    }
                }
                """
            }

            assertMacro {
                """
                @AllOfCodable
                struct NoCodableExample {
                    let brand: Brand
                }

                @AllOfCodable
                struct OnlyEncodableExample: Encodable {
                    let brand: Brand
                }

                @AllOfCodable
                struct OnlyDecodableExample: Decodable {
                    let brand: Brand
                }

                @AllOfCodable
                struct CodableExample: Codable {
                    let brand: Brand
                }
                """
            } expansion: {
                """
                struct NoCodableExample {
                    let brand: Brand
                }
                struct OnlyEncodableExample: Encodable {
                    let brand: Brand
                }
                struct OnlyDecodableExample: Decodable {
                    let brand: Brand
                }
                struct CodableExample: Codable {
                    let brand: Brand
                }

                extension NoCodableExample: Decodable, Encodable {
                    init(from decoder: Decoder) throws {
                        let container = try decoder.singleValueContainer()
                        self.brand = try container.decode(Brand.self)
                    }
                    func encode(to encoder: Encoder) throws {
                        try self.brand.encode(to: encoder)
                    }
                }

                extension OnlyEncodableExample: Decodable {
                    init(from decoder: Decoder) throws {
                        let container = try decoder.singleValueContainer()
                        self.brand = try container.decode(Brand.self)
                    }
                }

                extension OnlyDecodableExample: Encodable {
                    func encode(to encoder: Encoder) throws {
                        try self.brand.encode(to: encoder)
                    }
                }
                """
            }

            assertMacro {
                """
                @AllOfCodable
                struct Empty1 {
                    @OmitCoding
                    let brand: Brand
                }

                @AllOfCodable
                struct Empty2 {
                }

                @AllOfCodable
                struct Empty3 {
                    var string: String { "" }
                }
                """
            } expansion: {
                """
                struct Empty1 {
                    let brand: Brand
                }
                struct Empty2 {
                }
                struct Empty3 {
                    var string: String { "" }
                }

                extension Empty1: Decodable, Encodable {
                    init(from decoder: Decoder) throws {
                    }
                    func encode(to encoder: Encoder) throws {
                    }
                }

                extension Empty2: Decodable, Encodable {
                    init(from decoder: Decoder) throws {
                    }
                    func encode(to encoder: Encoder) throws {
                    }
                }

                extension Empty3: Decodable, Encodable {
                    init(from decoder: Decoder) throws {
                    }
                    func encode(to encoder: Encoder) throws {
                    }
                }
                """
            }

            assertMacro {
                """
                @AllOfCodable
                struct NoPublicCodable1 {
                    let brand: Brand
                }

                @AllOfCodable
                private struct NoPublicCodable2 {
                    let brand: Brand
                }

                @AllOfCodable
                internal struct NoPublicCodable3 {
                    let brand: Brand
                }

                @AllOfCodable
                public struct WithPublicCodable {
                }
                """
            } expansion: {
                """
                struct NoPublicCodable1 {
                    let brand: Brand
                }
                private struct NoPublicCodable2 {
                    let brand: Brand
                }
                internal struct NoPublicCodable3 {
                    let brand: Brand
                }
                public struct WithPublicCodable {
                }

                extension NoPublicCodable1: Decodable, Encodable {
                    init(from decoder: Decoder) throws {
                        let container = try decoder.singleValueContainer()
                        self.brand = try container.decode(Brand.self)
                    }
                    func encode(to encoder: Encoder) throws {
                        try self.brand.encode(to: encoder)
                    }
                }

                extension NoPublicCodable2: Decodable, Encodable {
                    init(from decoder: Decoder) throws {
                        let container = try decoder.singleValueContainer()
                        self.brand = try container.decode(Brand.self)
                    }
                    func encode(to encoder: Encoder) throws {
                        try self.brand.encode(to: encoder)
                    }
                }

                extension NoPublicCodable3: Decodable, Encodable {
                    init(from decoder: Decoder) throws {
                        let container = try decoder.singleValueContainer()
                        self.brand = try container.decode(Brand.self)
                    }
                    func encode(to encoder: Encoder) throws {
                        try self.brand.encode(to: encoder)
                    }
                }

                extension WithPublicCodable: Decodable, Encodable {
                    public init(from decoder: Decoder) throws {
                    }
                    public func encode(to encoder: Encoder) throws {
                    }
                }
                """
            }
        }
    }
}
