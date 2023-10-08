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
                enum NoApplicable {}
                """
            } diagnostics: {
                """
                @Codable
                ╰─ 🛑 '@Codable' macro can only be applied to a struct
                enum NoApplicable {}
                """
            }

            assertMacro {
                """
                @Codable
                class NoApplicable {}
                """
            } diagnostics: {
                """
                @Codable
                ╰─ 🛑 '@Codable' macro can only be applied to a struct
                class NoApplicable {}
                """
            }

            assertMacro {
                """
                @Codable
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

                extension Example: Decodable, Encodable {
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
                struct NoCodableExample {
                    let brand: Brand
                }

                @Codable
                struct OnlyEncodableExample: Encodable {
                    let brand: Brand
                }

                @Codable
                struct OnlyDecodableExample: Decodable {
                    let brand: Brand
                }

                @Codable
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

                extension OnlyEncodableExample: Decodable {
                    enum CodingKeys: String, CodingKey {
                        case brand
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        self.brand = try container.decode(Brand.self, forKey: .brand)
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
                @Codable
                struct Empty1 {
                    @OmitCoding
                    let brand: Brand
                }

                @Codable
                struct Empty2 {
                }

                @Codable
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
                @Codable
                struct NoPublicCodable1 {
                    let brand: Brand
                }

                @Codable
                private struct NoPublicCodable2 {
                    let brand: Brand
                }

                @Codable
                internal struct NoPublicCodable3 {
                    let brand: Brand
                }

                @Codable
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

                extension NoPublicCodable2: Decodable, Encodable {
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

                extension NoPublicCodable3: Decodable, Encodable {
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
