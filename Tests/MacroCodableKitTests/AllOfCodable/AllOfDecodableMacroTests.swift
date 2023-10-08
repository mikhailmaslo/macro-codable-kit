//
//  AllOfDecodableMacroTests.swift
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

final class AllOfDecodableMacroTests: XCTestCase {
    func test() throws {
        withMacroTesting(
            isRecording: isRecording,
            macros: [
                "AllOfDecodable": AllOfDecodableMacro.self,
                "OmitCoding": OmitCodingMacro.self,
            ]
        ) {
            assertMacro {
                """
                @AllOfDecodable
                enum NotApplicable\(sutSuffix) {}
                """
            } diagnostics: {
                """
                @AllOfDecodable
                ╰─ 🛑 '@AllOfDecodable' macro can only be applied to a struct
                enum NotApplicable__testing__ {}
                """
            }

            assertMacro {
                """
                @AllOfDecodable
                class NotApplicable\(sutSuffix) {}
                """
            } diagnostics: {
                """
                @AllOfDecodable
                ╰─ 🛑 '@AllOfDecodable' macro can only be applied to a struct
                class NotApplicable__testing__ {}
                """
            }

            assertMacro {
                """
                @AllOfDecodable
                struct Example\(sutSuffix) {
                    let brand: Brand?
                    let company: Company
                    @OmitCoding
                    let omittedCompany: Company
                }
                """
            } expansion: {
                """
                struct Example__testing__ {
                    let brand: Brand?
                    let company: Company
                    let omittedCompany: Company
                }

                extension Example__testing__: Decodable {
                    init(from decoder: Decoder) throws {
                        let container = try decoder.singleValueContainer()
                        self.brand = try container.decodeIfPresent(Brand.self)
                        self.company = try container.decode(Company.self)
                    }
                }
                """
            }

            assertMacro {
                """
                @AllOfDecodable
                struct NoCodableExample\(sutSuffix) {
                    let brand: Brand
                }

                @AllOfDecodable
                struct OnlyEncodableExample\(sutSuffix): Encodable {
                    let brand: Brand
                }

                @AllOfDecodable
                struct OnlyDecodableExample\(sutSuffix): Decodable {
                    let brand: Brand
                }

                @AllOfDecodable
                struct CodableExample\(sutSuffix): Codable {
                    let brand: Brand
                }
                """
            } diagnostics: {
                """
                @AllOfDecodable
                struct NoCodableExample__testing__ {
                    let brand: Brand
                }

                @AllOfDecodable
                struct OnlyEncodableExample__testing__: Encodable {
                    let brand: Brand
                }

                @AllOfDecodable
                ╰─ ⚠️ '@AllOfDecodable' macro has not effect since 'OnlyDecodableExample__testing__' already conformes to ["Decodable"]. Consider removing '@AllOfDecodable'
                struct OnlyDecodableExample__testing__: Decodable {
                    let brand: Brand
                }

                @AllOfDecodable
                ╰─ ⚠️ '@AllOfDecodable' macro has not effect since 'CodableExample__testing__' already conformes to ["Decodable"]. Consider removing '@AllOfDecodable'
                struct CodableExample__testing__: Codable {
                    let brand: Brand
                }
                """
            } expansion: {
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

                extension NoCodableExample__testing__: Decodable {
                    init(from decoder: Decoder) throws {
                        let container = try decoder.singleValueContainer()
                        self.brand = try container.decode(Brand.self)
                    }
                }

                extension OnlyEncodableExample__testing__: Decodable {
                    init(from decoder: Decoder) throws {
                        let container = try decoder.singleValueContainer()
                        self.brand = try container.decode(Brand.self)
                    }
                }
                """
            }

            assertMacro {
                """
                @AllOfDecodable
                struct Empty1\(sutSuffix) {
                    @OmitCoding
                    let brand: Brand
                }

                @AllOfDecodable
                struct Empty2\(sutSuffix) {
                }
                """
            } diagnostics: {
                """

                """
            } expansion: {
                """
                struct Empty1__testing__ {
                    let brand: Brand
                }
                struct Empty2__testing__ {
                }

                extension Empty1__testing__: Decodable {
                    init(from decoder: Decoder) throws {
                    }
                }

                extension Empty2__testing__: Decodable {
                    init(from decoder: Decoder) throws {
                    }
                }
                """
            }

            assertMacro {
                """
                @AllOfDecodable
                struct NoPublicCodable1\(sutSuffix) {
                    let brand: Brand
                }

                @AllOfDecodable
                private struct NoPublicCodable2\(sutSuffix) {
                    let brand: Brand
                }

                @AllOfDecodable
                internal struct NoPublicCodable3\(sutSuffix) {
                    let brand: Brand
                }

                @AllOfDecodable
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

                extension NoPublicCodable1__testing__: Decodable {
                    init(from decoder: Decoder) throws {
                        let container = try decoder.singleValueContainer()
                        self.brand = try container.decode(Brand.self)
                    }
                }

                extension NoPublicCodable2__testing__: Decodable {
                    init(from decoder: Decoder) throws {
                        let container = try decoder.singleValueContainer()
                        self.brand = try container.decode(Brand.self)
                    }
                }

                extension NoPublicCodable3__testing__: Decodable {
                    init(from decoder: Decoder) throws {
                        let container = try decoder.singleValueContainer()
                        self.brand = try container.decode(Brand.self)
                    }
                }

                extension WithPublicCodable__testing__: Decodable {
                    public init(from decoder: Decoder) throws {
                    }
                }
                """
            }
        }
    }
}
