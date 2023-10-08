//
//  EncodableMacroTests.swift
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

final class EncodableMacroTests: XCTestCase {
    func test() {
        withMacroTesting(
            isRecording: isRecording,
            macros: [
                "Encodable": EncodableMacro.self,
                "OmitCoding": OmitCodingMacro.self,
                "CodingKey": CodingKeyMacro.self,
            ]
        ) {
            assertMacro {
                """
                @Encodable
                enum NoApplicable {}
                """
            } diagnostics: {
                """
                @Encodable
                ╰─ 🛑 'Encodable' macro can only be applied to a struct
                enum NoApplicable {}
                """
            }

            assertMacro {
                """
                @Encodable
                class NoApplicable {}
                """
            } diagnostics: {
                """
                @Encodable
                ╰─ 🛑 'Encodable' macro can only be applied to a struct
                class NoApplicable {}
                """
            }

            assertMacro {
                """
                @Encodable
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

                extension Example: Encodable {
                    enum CodingKeys: String, CodingKey {
                        case brand
                        case company
                        case customCompanyKey = "custom_company"
                        case available = "_available"
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        try container.encodeIfPresent(self.brand, forKey: .brand)
                        try container.encode(self.company, forKey: .company)
                        try container.encode(self.customCompanyKey, forKey: .customCompanyKey)
                        try container.encode(self.available, forKey: .available)
                    }
                }
                """
            }

            assertMacro {
                """
                @Encodable
                struct NoCodableExample {
                    let brand: Brand
                }

                @Encodable
                struct OnlyEncodableExample: Encodable {
                    let brand: Brand
                }

                @Encodable
                struct OnlyDecodableExample: Decodable {
                    let brand: Brand
                }

                @Encodable
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

                extension NoCodableExample: Encodable {
                    enum CodingKeys: String, CodingKey {
                        case brand
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        try container.encode(self.brand, forKey: .brand)
                    }
                }

                extension OnlyDecodableExample: Encodable {
                    enum CodingKeys: String, CodingKey {
                        case brand
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        try container.encode(self.brand, forKey: .brand)
                    }
                }
                """
            }

            assertMacro {
                """
                @Encodable
                struct Empty1 {
                    @OmitCoding
                    let brand: Brand
                }

                @Encodable
                struct Empty2 {
                }

                @Encodable
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

                extension Empty1: Encodable {
                    func encode(to encoder: Encoder) throws {
                    }
                }

                extension Empty2: Encodable {
                    func encode(to encoder: Encoder) throws {
                    }
                }

                extension Empty3: Encodable {
                    func encode(to encoder: Encoder) throws {
                    }
                }
                """
            }

            assertMacro {
                """
                @Encodable
                struct NoPublicCodable1 {
                    let brand: Brand
                }

                @Encodable
                private struct NoPublicCodable2 {
                    let brand: Brand
                }

                @Encodable
                internal struct NoPublicCodable3 {
                    let brand: Brand
                }

                @Encodable
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

                extension NoPublicCodable1: Encodable {
                    enum CodingKeys: String, CodingKey {
                        case brand
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        try container.encode(self.brand, forKey: .brand)
                    }
                }

                extension NoPublicCodable2: Encodable {
                    enum CodingKeys: String, CodingKey {
                        case brand
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        try container.encode(self.brand, forKey: .brand)
                    }
                }

                extension NoPublicCodable3: Encodable {
                    enum CodingKeys: String, CodingKey {
                        case brand
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        try container.encode(self.brand, forKey: .brand)
                    }
                }

                extension WithPublicCodable: Encodable {
                    public func encode(to encoder: Encoder) throws {
                    }
                }
                """
            }
        }
    }
}
