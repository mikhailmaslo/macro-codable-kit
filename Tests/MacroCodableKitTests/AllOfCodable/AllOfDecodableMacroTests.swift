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
                enum NotApplicable {}
                """
            } diagnostics: {
                """
                @AllOfDecodable
                ╰─ 🛑 'AllOfDecodable' macro can only be applied to a struct
                enum NotApplicable {}
                """
            }

            assertMacro {
                """
                @AllOfDecodable
                class NotApplicable {}
                """
            } diagnostics: {
                """
                @AllOfDecodable
                ╰─ 🛑 'AllOfDecodable' macro can only be applied to a struct
                class NotApplicable {}
                """
            }

            assertMacro {
                """
                @AllOfDecodable
                struct Example {
                    let brand: Brand?
                    let company: Company
                    @OmitCoding
                    let omittedCompany: Company
                }
                """
            } expansion: {
                """
                struct Example {
                    let brand: Brand?
                    let company: Company
                    let omittedCompany: Company
                }

                extension Example: Decodable {
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
                struct NoCodableExample {
                    let brand: Brand
                }

                @AllOfDecodable
                struct OnlyEncodableExample: Encodable {
                    let brand: Brand
                }

                @AllOfDecodable
                struct OnlyDecodableExample: Decodable {
                    let brand: Brand
                }

                @AllOfDecodable
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

                extension NoCodableExample: Decodable {
                    init(from decoder: Decoder) throws {
                        let container = try decoder.singleValueContainer()
                        self.brand = try container.decode(Brand.self)
                    }
                }

                extension OnlyEncodableExample: Decodable {
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
                struct Empty1 {
                    @OmitCoding
                    let brand: Brand
                }

                @AllOfDecodable
                struct Empty2 {
                }
                """
            } expansion: {
                """
                struct Empty1 {
                    let brand: Brand
                }
                struct Empty2 {
                }

                extension Empty1: Decodable {
                    init(from decoder: Decoder) throws {
                    }
                }

                extension Empty2: Decodable {
                    init(from decoder: Decoder) throws {
                    }
                }
                """
            }

            assertMacro {
                """
                @AllOfDecodable
                struct NoPublicCodable1 {
                    let brand: Brand
                }

                @AllOfDecodable
                private struct NoPublicCodable2 {
                    let brand: Brand
                }

                @AllOfDecodable
                internal struct NoPublicCodable3 {
                    let brand: Brand
                }

                @AllOfDecodable
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

                extension NoPublicCodable1: Decodable {
                    init(from decoder: Decoder) throws {
                        let container = try decoder.singleValueContainer()
                        self.brand = try container.decode(Brand.self)
                    }
                }

                extension NoPublicCodable2: Decodable {
                    init(from decoder: Decoder) throws {
                        let container = try decoder.singleValueContainer()
                        self.brand = try container.decode(Brand.self)
                    }
                }

                extension NoPublicCodable3: Decodable {
                    init(from decoder: Decoder) throws {
                        let container = try decoder.singleValueContainer()
                        self.brand = try container.decode(Brand.self)
                    }
                }

                extension WithPublicCodable: Decodable {
                    public init(from decoder: Decoder) throws {
                    }
                }
                """
            }
        }
    }
}
