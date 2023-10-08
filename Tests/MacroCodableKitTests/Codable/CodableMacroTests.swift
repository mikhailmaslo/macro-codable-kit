//
//  CodableMacroTests.swift
//
//
//  Created by Mikhail Maslo on 25.09.23.
//

import Macro
import MacroTesting
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

private let isRecording = false

final class CodableMacroTests: XCTestCase {
    func test() {
        withMacroTesting(
            isRecording: isRecording,
            macros: [
                "Codable": CodableMacro.self,
                "OmitCoding": OmitCodingMacro.self,
                "CodingKey": CodingKeyMacro.self,
            ]
        ) {
            assertMacro {
                """
                @Codable
                enum NoApplicable\(sutSuffix) {}
                """
            } diagnostics: {
                """
                @Codable
                ╰─ 🛑 '@Codable' macro can only be applied to a struct
                enum NoApplicable__testing__ {}
                """
            }

            assertMacro {
                """
                @Codable
                class NoApplicable\(sutSuffix) {}
                """
            } diagnostics: {
                """
                @Codable
                ╰─ 🛑 '@Codable' macro can only be applied to a struct
                class NoApplicable__testing__ {}
                """
            }

            assertMacro {
                """
                @Codable
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

                extension Example__testing__: Decodable, Encodable {
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
                @Codable
                struct NoCodableExample\(sutSuffix) {
                    let brand: Brand
                }

                @Codable
                struct OnlyEncodableExample\(sutSuffix): Encodable {
                    let brand: Brand
                }

                @Codable
                struct OnlyDecodableExample\(sutSuffix): Decodable {
                    let brand: Brand
                }

                @Codable
                struct CodableExample\(sutSuffix): Codable {
                    let brand: Brand
                }
                """
            } diagnostics: {
                """
                @Codable
                struct NoCodableExample__testing__ {
                    let brand: Brand
                }

                @Codable
                ╰─ ⚠️ '@Codable' macro won't generate 'Encodable' conformance since 'OnlyEncodableExample__testing__' already conformes to it. Consider using '@Decodable' instead
                struct OnlyEncodableExample__testing__: Encodable {
                    let brand: Brand
                }

                @Codable
                ╰─ ⚠️ '@Codable' macro won't generate 'Decodable' conformance since 'OnlyDecodableExample__testing__' already conformes to it. Consider using '@Encodable' instead
                struct OnlyDecodableExample__testing__: Decodable {
                    let brand: Brand
                }

                @Codable
                ╰─ ⚠️ '@Codable' macro has not effect since 'CodableExample__testing__' already conformes to ["Decodable", "Encodable"]. Consider removing '@Codable'
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

                extension NoCodableExample__testing__: Decodable, Encodable {
                    enum CodingKeys: String, CodingKey {
                        case brand
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        self.brand = try container.decode(Brand.self, forKey: .brand)
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        try container.encode(self.brand, forKey: .brand)
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
                @Codable
                struct Empty1\(sutSuffix) {
                    @OmitCoding
                    let brand: Brand
                }

                @Codable
                struct Empty2\(sutSuffix) {
                }

                @Codable
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
                @Codable
                struct NoPublicCodable1\(sutSuffix) {
                    let brand: Brand
                }

                @Codable
                private struct NoPublicCodable2\(sutSuffix) {
                    let brand: Brand
                }

                @Codable
                internal struct NoPublicCodable3\(sutSuffix) {
                    let brand: Brand
                }

                @Codable
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
                    enum CodingKeys: String, CodingKey {
                        case brand
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        self.brand = try container.decode(Brand.self, forKey: .brand)
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        try container.encode(self.brand, forKey: .brand)
                    }
                }

                extension NoPublicCodable2__testing__: Decodable, Encodable {
                    enum CodingKeys: String, CodingKey {
                        case brand
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        self.brand = try container.decode(Brand.self, forKey: .brand)
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        try container.encode(self.brand, forKey: .brand)
                    }
                }

                extension NoPublicCodable3__testing__: Decodable, Encodable {
                    enum CodingKeys: String, CodingKey {
                        case brand
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        self.brand = try container.decode(Brand.self, forKey: .brand)
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        try container.encode(self.brand, forKey: .brand)
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
