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
                enum NoApplicable\(sutSuffix) {}
                """
            } diagnostics: {
                """
                @Decodable
                ╰─ 🛑 '@Decodable' macro can only be applied to a struct
                enum NoApplicable__testing__ {}
                """
            }

            assertMacro {
                """
                @Decodable
                class NoApplicable\(sutSuffix) {}
                """
            } diagnostics: {
                """
                @Decodable
                ╰─ 🛑 '@Decodable' macro can only be applied to a struct
                class NoApplicable__testing__ {}
                """
            }

            assertMacro {
                """
                @Decodable
                struct Example\(sutSuffix) {
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
                struct Example__testing__ {
                    let brand: Brand?
                    let company: Company
                    let omittedCompany: Company
                    let customCompanyKey: Company

                    var string: String { "" }
                    @available(*, iOS)
                    let available: Bool
                }

                extension Example__testing__: Decodable {
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
                struct NoCodableExample\(sutSuffix) {
                    let brand: Brand
                }

                @Decodable
                struct OnlyEncodableExample\(sutSuffix): Encodable {
                    let brand: Brand
                }

                @Decodable
                struct OnlyDecodableExample\(sutSuffix): Decodable {
                    let brand: Brand
                }

                @Decodable
                struct CodableExample\(sutSuffix): Codable {
                    let brand: Brand
                }
                """
            } diagnostics: {
                """
                @Decodable
                struct NoCodableExample__testing__ {
                    let brand: Brand
                }

                @Decodable
                struct OnlyEncodableExample__testing__: Encodable {
                    let brand: Brand
                }

                @Decodable
                ╰─ ⚠️ '@Decodable' macro has not effect since 'OnlyDecodableExample__testing__' already conformes to ["Decodable"]. Consider removing '@Decodable'
                struct OnlyDecodableExample__testing__: Decodable {
                    let brand: Brand
                }

                @Decodable
                ╰─ ⚠️ '@Decodable' macro has not effect since 'CodableExample__testing__' already conformes to ["Decodable"]. Consider removing '@Decodable'
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
                    enum CodingKeys: String, CodingKey {
                        case brand
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        self.brand = try container.decode(Brand.self, forKey: .brand)
                    }
                }

                extension OnlyEncodableExample__testing__: Decodable {
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
                struct Empty1\(sutSuffix) {
                    @OmitCoding
                    let brand: Brand
                }

                @Decodable
                struct Empty2\(sutSuffix) {
                }

                @Decodable
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

                extension Empty1__testing__: Decodable {
                    init(from decoder: Decoder) throws {
                    }
                }

                extension Empty2__testing__: Decodable {
                    init(from decoder: Decoder) throws {
                    }
                }

                extension Empty3__testing__: Decodable {
                    init(from decoder: Decoder) throws {
                    }
                }
                """
            }

            assertMacro {
                """
                @Decodable
                struct NoAccessorSpecifier\(sutSuffix) {
                    let brand: Brand
                }

                @Decodable
                private struct NoPublicCodable2\(sutSuffix) {
                    let brand: Brand
                }

                @Decodable
                internal struct NoPublicCodable3\(sutSuffix) {
                    let brand: Brand
                }

                @Decodable
                public struct WithPublicCodable\(sutSuffix) {
                }
                """
            } expansion: {
                """
                struct NoAccessorSpecifier__testing__ {
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

                extension NoAccessorSpecifier__testing__: Decodable {
                    enum CodingKeys: String, CodingKey {
                        case brand
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        self.brand = try container.decode(Brand.self, forKey: .brand)
                    }
                }

                extension NoPublicCodable2__testing__: Decodable {
                    enum CodingKeys: String, CodingKey {
                        case brand
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        self.brand = try container.decode(Brand.self, forKey: .brand)
                    }
                }

                extension NoPublicCodable3__testing__: Decodable {
                    enum CodingKeys: String, CodingKey {
                        case brand
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        self.brand = try container.decode(Brand.self, forKey: .brand)
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
