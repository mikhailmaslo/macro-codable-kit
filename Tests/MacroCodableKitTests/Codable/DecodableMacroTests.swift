//
//  DecodableMacroTests.swift
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

final class DecodableMacroTests: XCTestCase {
    func test() {
        withMacroTesting(
            isRecording: isRecording,
            macros: [
                "Decodable": DecodableMacro.self,
                "OmitCoding": OmitCodingMacro.self,
                "CodingKey": CodingKeyMacro.self,
            ]
        ) {
            assertMacro {
                """
                @Decodable
                enum NoApplicable {}
                """
            } diagnostics: {
                """
                @Decodable
                ╰─ 🛑 'Decodable' macro can only be applied to a struct
                enum NoApplicable {}
                """
            }

            assertMacro {
                """
                @Decodable
                class NoApplicable {}
                """
            } diagnostics: {
                """
                @Decodable
                ╰─ 🛑 'Decodable' macro can only be applied to a struct
                class NoApplicable {}
                """
            }

            assertMacro {
                """
                @Decodable
                struct Example {
                    let brand: Brand?
                    let company: Company

                    @OmitCoding
                    let omittedCompany: Company

                    @CodingKey("custom_company")
                    let customCompanyKey: Company

                    var string: String { "" }

                    @CodingKey("_available")
                    @available(*, iOS)
                    let available: Bool
                }
                """
            } expansion: {
                """
                struct Example {
                    let brand: Brand?
                    let company: Company
                    let omittedCompany: Company
                    let customCompanyKey: Company

                    var string: String { "" }
                    @available(*, iOS)
                    let available: Bool
                }

                extension Example: Decodable {
                    enum CodingKeys: String, CodingKey {
                        case brand
                        case company
                        case customCompanyKey = "custom_company"
                        case available = "_available"
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        self.brand = try container.decodeIfPresent(Brand.self, forKey: .brand)
                        self.company = try container.decode(Company.self, forKey: .company)
                        self.customCompanyKey = try container.decode(Company.self, forKey: .customCompanyKey)
                        self.available = try container.decode(Bool.self, forKey: .available)
                    }
                }
                """
            }

            assertMacro {
                """
                @Decodable
                struct NoCodableExample {
                    let brand: Brand
                }

                @Decodable
                struct OnlyEncodableExample: Encodable {
                    let brand: Brand
                }

                @Decodable
                struct OnlyDecodableExample: Decodable {
                    let brand: Brand
                }

                @Decodable
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
                    enum CodingKeys: String, CodingKey {
                        case brand
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        self.brand = try container.decode(Brand.self, forKey: .brand)
                    }
                }

                extension OnlyEncodableExample: Decodable {
                    enum CodingKeys: String, CodingKey {
                        case brand
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        self.brand = try container.decode(Brand.self, forKey: .brand)
                    }
                }
                """
            }

            assertMacro {
                """
                @Decodable
                struct Empty1 {
                    @OmitCoding
                    let brand: Brand
                }

                @Decodable
                struct Empty2 {
                }

                @Decodable
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

                extension Empty1: Decodable {
                    init(from decoder: Decoder) throws {
                    }
                }

                extension Empty2: Decodable {
                    init(from decoder: Decoder) throws {
                    }
                }

                extension Empty3: Decodable {
                    init(from decoder: Decoder) throws {
                    }
                }
                """
            }

            assertMacro {
                """
                @Decodable
                struct NoAccessorSpecifier {
                    let brand: Brand
                }

                @Decodable
                private struct NoPublicCodable2 {
                    let brand: Brand
                }

                @Decodable
                internal struct NoPublicCodable3 {
                    let brand: Brand
                }

                @Decodable
                public struct WithPublicCodable {
                }
                """
            } expansion: {
                """
                struct NoAccessorSpecifier {
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

                extension NoAccessorSpecifier: Decodable {
                    enum CodingKeys: String, CodingKey {
                        case brand
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        self.brand = try container.decode(Brand.self, forKey: .brand)
                    }
                }

                extension NoPublicCodable2: Decodable {
                    enum CodingKeys: String, CodingKey {
                        case brand
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        self.brand = try container.decode(Brand.self, forKey: .brand)
                    }
                }

                extension NoPublicCodable3: Decodable {
                    enum CodingKeys: String, CodingKey {
                        case brand
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        self.brand = try container.decode(Brand.self, forKey: .brand)
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
