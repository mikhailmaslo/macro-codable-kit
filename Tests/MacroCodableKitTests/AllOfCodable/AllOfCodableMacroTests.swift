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
                enum NotApplicable\(sutSuffix) {}
                """
            } diagnostics: {
                """
                @AllOfCodable
                ╰─ 🛑 '@AllOfCodable' macro can only be applied to a struct
                enum NotApplicable__testing__ {}
                """
            }

            assertMacro {
                """
                @AllOfCodable
                class NotApplicable\(sutSuffix) {}
                """
            } diagnostics: {
                """
                @AllOfCodable
                ╰─ 🛑 '@AllOfCodable' macro can only be applied to a struct
                class NotApplicable__testing__ {}
                """
            }

            assertMacro {
                """
                @AllOfCodable
                struct Example\(sutSuffix) {
                    let brand: Brand?
                    let company: Company
                    @OmitCoding
                    let omittedCompany: Company

                    var string: String { "" }
                }
                """
            } expansion: {
                """
                struct Example__testing__ {
                    let brand: Brand?
                    let company: Company
                    let omittedCompany: Company

                    var string: String { "" }
                }

                extension Example__testing__: Decodable, Encodable {
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
                struct NoCodableExample\(sutSuffix) {
                    let brand: Brand
                }

                @AllOfCodable
                struct OnlyEncodableExample\(sutSuffix): Encodable {
                    let brand: Brand
                }

                @AllOfCodable
                struct OnlyDecodableExample\(sutSuffix): Decodable {
                    let brand: Brand
                }

                @AllOfCodable
                struct CodableExample\(sutSuffix): Codable {
                    let brand: Brand
                }
                """
            } diagnostics: {
                """
                @AllOfCodable
                struct NoCodableExample__testing__ {
                    let brand: Brand
                }

                @AllOfCodable
                ╰─ ⚠️ '@AllOfCodable' macro won't generate 'Encodable' conformance since 'OnlyEncodableExample__testing__' already conformes to it. Consider using '@AllOfDecodable' instead
                struct OnlyEncodableExample__testing__: Encodable {
                    let brand: Brand
                }

                @AllOfCodable
                ╰─ ⚠️ '@AllOfCodable' macro won't generate 'Decodable' conformance since 'OnlyDecodableExample__testing__' already conformes to it. Consider using '@AllOfEncodable' instead
                struct OnlyDecodableExample__testing__: Decodable {
                    let brand: Brand
                }

                @AllOfCodable
                ╰─ ⚠️ '@AllOfCodable' macro has not effect since 'CodableExample__testing__' already conformes to ["Decodable", "Encodable"]. Consider removing '@AllOfCodable'
                struct CodableExample__testing__: Codable {
                    let brand: Brand
                }
                """
            }expansion: {
                """
                struct NoCodableExample__testing__ {
                    let brand: Brand
                }
                struct OnlyEncodableExample__testing__: Encodable {
                    let brand: Brand
                }
                struct OnlyDecodableExample__testing__: Decodable {
                    let brand: Brand
                }
                struct CodableExample__testing__: Codable {
                    let brand: Brand
                }

                extension NoCodableExample__testing__: Decodable, Encodable {
                    init(from decoder: Decoder) throws {
                        let container = try decoder.singleValueContainer()
                        self.brand = try container.decode(Brand.self)
                    }
                    func encode(to encoder: Encoder) throws {
                        try self.brand.encode(to: encoder)
                    }
                }

                extension OnlyEncodableExample__testing__: Decodable {
                    init(from decoder: Decoder) throws {
                        let container = try decoder.singleValueContainer()
                        self.brand = try container.decode(Brand.self)
                    }
                }

                extension OnlyDecodableExample__testing__: Encodable {
                    func encode(to encoder: Encoder) throws {
                        try self.brand.encode(to: encoder)
                    }
                }
                """
            }

            assertMacro {
                """
                @AllOfCodable
                struct Empty1\(sutSuffix) {
                    @OmitCoding
                    let brand: Brand
                }

                @AllOfCodable
                struct Empty2\(sutSuffix) {
                }

                @AllOfCodable
                struct Empty3\(sutSuffix) {
                    var string: String { "" }
                }
                """
            } expansion: {
                """
                struct Empty1__testing__ {
                    let brand: Brand
                }
                struct Empty2__testing__ {
                }
                struct Empty3__testing__ {
                    var string: String { "" }
                }

                extension Empty1__testing__: Decodable, Encodable {
                    init(from decoder: Decoder) throws {
                    }
                    func encode(to encoder: Encoder) throws {
                    }
                }

                extension Empty2__testing__: Decodable, Encodable {
                    init(from decoder: Decoder) throws {
                    }
                    func encode(to encoder: Encoder) throws {
                    }
                }

                extension Empty3__testing__: Decodable, Encodable {
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
                struct NoPublicCodable1\(sutSuffix) {
                    let brand: Brand
                }

                @AllOfCodable
                private struct NoPublicCodable2\(sutSuffix) {
                    let brand: Brand
                }

                @AllOfCodable
                internal struct NoPublicCodable3\(sutSuffix) {
                    let brand: Brand
                }

                @AllOfCodable
                public struct WithPublicCodable\(sutSuffix) {
                }
                """
            } expansion: {
                """
                struct NoPublicCodable1__testing__ {
                    let brand: Brand
                }
                private struct NoPublicCodable2__testing__ {
                    let brand: Brand
                }
                internal struct NoPublicCodable3__testing__ {
                    let brand: Brand
                }
                public struct WithPublicCodable__testing__ {
                }

                extension NoPublicCodable1__testing__: Decodable, Encodable {
                    init(from decoder: Decoder) throws {
                        let container = try decoder.singleValueContainer()
                        self.brand = try container.decode(Brand.self)
                    }
                    func encode(to encoder: Encoder) throws {
                        try self.brand.encode(to: encoder)
                    }
                }

                extension NoPublicCodable2__testing__: Decodable, Encodable {
                    init(from decoder: Decoder) throws {
                        let container = try decoder.singleValueContainer()
                        self.brand = try container.decode(Brand.self)
                    }
                    func encode(to encoder: Encoder) throws {
                        try self.brand.encode(to: encoder)
                    }
                }

                extension NoPublicCodable3__testing__: Decodable, Encodable {
                    init(from decoder: Decoder) throws {
                        let container = try decoder.singleValueContainer()
                        self.brand = try container.decode(Brand.self)
                    }
                    func encode(to encoder: Encoder) throws {
                        try self.brand.encode(to: encoder)
                    }
                }

                extension WithPublicCodable__testing__: Decodable, Encodable {
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
