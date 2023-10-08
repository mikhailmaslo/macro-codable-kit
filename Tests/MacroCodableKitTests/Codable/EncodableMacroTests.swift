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
                enum NoApplicable\(sutSuffix) {}
                """
            } diagnostics: {
                """
                @Encodable
                ╰─ 🛑 '@Encodable' macro can only be applied to a struct
                enum NoApplicable__testing__ {}
                """
            }

            assertMacro {
                """
                @Encodable
                class NoApplicable\(sutSuffix) {}
                """
            } diagnostics: {
                """
                @Encodable
                ╰─ 🛑 '@Encodable' macro can only be applied to a struct
                class NoApplicable__testing__ {}
                """
            }

            assertMacro {
                """
                @Encodable
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

                extension Example__testing__: Encodable {
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
                struct NoCodableExample\(sutSuffix) {
                    let brand: Brand
                }

                @Encodable
                struct OnlyEncodableExample\(sutSuffix): Encodable {
                    let brand: Brand
                }

                @Encodable
                struct OnlyDecodableExample\(sutSuffix): Decodable {
                    let brand: Brand
                }

                @Encodable
                struct CodableExample\(sutSuffix): Codable {
                    let brand: Brand
                }
                """
            } diagnostics: {
                """
                @Encodable
                struct NoCodableExample__testing__ {
                    let brand: Brand
                }

                @Encodable
                ╰─ ⚠️ '@Encodable' macro has not effect since 'OnlyEncodableExample__testing__' already conformes to ["Encodable"]. Consider removing '@Encodable'
                struct OnlyEncodableExample__testing__: Encodable {
                    let brand: Brand
                }

                @Encodable
                struct OnlyDecodableExample__testing__: Decodable {
                    let brand: Brand
                }

                @Encodable
                ╰─ ⚠️ '@Encodable' macro has not effect since 'CodableExample__testing__' already conformes to ["Encodable"]. Consider removing '@Encodable'
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

                extension NoCodableExample__testing__: Encodable {
                    enum CodingKeys: String, CodingKey {
                        case brand
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        try container.encode(self.brand, forKey: .brand)
                    }
                }

                extension OnlyDecodableExample__testing__: Encodable {
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
                struct Empty1\(sutSuffix) {
                    @OmitCoding
                    let brand: Brand
                }

                @Encodable
                struct Empty2\(sutSuffix) {
                }

                @Encodable
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

                extension Empty1__testing__: Encodable {
                    func encode(to encoder: Encoder) throws {
                    }
                }

                extension Empty2__testing__: Encodable {
                    func encode(to encoder: Encoder) throws {
                    }
                }

                extension Empty3__testing__: Encodable {
                    func encode(to encoder: Encoder) throws {
                    }
                }
                """
            }

            assertMacro {
                """
                @Encodable
                struct NoPublicCodable1\(sutSuffix) {
                    let brand: Brand
                }

                @Encodable
                private struct NoPublicCodable2\(sutSuffix) {
                    let brand: Brand
                }

                @Encodable
                internal struct NoPublicCodable3\(sutSuffix) {
                    let brand: Brand
                }

                @Encodable
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

                extension NoPublicCodable1__testing__: Encodable {
                    enum CodingKeys: String, CodingKey {
                        case brand
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        try container.encode(self.brand, forKey: .brand)
                    }
                }

                extension NoPublicCodable2__testing__: Encodable {
                    enum CodingKeys: String, CodingKey {
                        case brand
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        try container.encode(self.brand, forKey: .brand)
                    }
                }

                extension NoPublicCodable3__testing__: Encodable {
                    enum CodingKeys: String, CodingKey {
                        case brand
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        try container.encode(self.brand, forKey: .brand)
                    }
                }

                extension WithPublicCodable__testing__: Encodable {
                    public func encode(to encoder: Encoder) throws {
                    }
                }
                """
            }
        }
    }
}
