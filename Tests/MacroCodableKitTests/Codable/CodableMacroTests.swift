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
    func test_Codable() {
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
                enum A {}
                """
            } diagnostics: {
                """
                @Codable
                ┬───────
                ╰─ 🛑 'Codable' macro can only be applied to a struct or to a class
                enum A {}
                """
            }

            assertMacro {
                """
                @Codable
                struct A: Encodable {
                    let brand: Brand
                    let company: Company
                }
                """
            } expansion: {
                """
                struct A: Encodable {
                    let brand: Brand
                    let company: Company
                }

                extension A: Decodable {
                    enum CodingKeys: String, CodingKey {
                        case brand
                        case company
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        self.brand = try container.decode(Brand.self, forKey: .brand)
                        self.company = try container.decode(Company.self, forKey: .company)
                    }
                }
                """
            }

            assertMacro {
                """
                @Codable
                struct A: Decodable {
                    let brand: Brand
                    let company: Company
                }
                """
            } expansion: {
                """
                struct A: Decodable {
                    let brand: Brand
                    let company: Company
                }

                extension A: Encodable {
                    enum CodingKeys: String, CodingKey {
                        case brand
                        case company
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        try container.encode(self.brand, forKey: .brand)
                        try container.encode(self.company, forKey: .company)
                    }
                }
                """
            }

            assertMacro {
                """
                @Codable
                struct A: Codable {
                    let brand: Brand
                    let company: Company
                }
                """
            } expansion: {
                """
                struct A: Codable {
                    let brand: Brand
                    let company: Company
                }
                """
            }

            assertMacro {
                """
                @Codable
                struct A: Encodable, Decodable {
                    let brand: Brand
                    let company: Company
                }
                """
            } expansion: {
                """
                struct A: Encodable, Decodable {
                    let brand: Brand
                    let company: Company
                }
                """
            }

            assertMacro {
                """
                @Codable
                private struct A {
                    let brand: Brand
                    @OmitCoding
                    let company: Company
                }
                """
            } expansion: {
                """
                private struct A {
                    let brand: Brand
                    let company: Company
                }

                extension A: Decodable, Encodable {
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
                """
            }

            assertMacro {
                """
                @Codable
                public struct A {
                    let brand: Brand
                    @CodingKey("_company")
                    let company: Company
                }
                """
            } expansion: {
                """
                public struct A {
                    let brand: Brand
                    let company: Company
                }

                extension A: Decodable, Encodable {
                    public enum CodingKeys: String, CodingKey {
                        case brand
                        case company = "_company"
                    }
                    public init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        self.brand = try container.decode(Brand.self, forKey: .brand)
                        self.company = try container.decode(Company.self, forKey: .company)
                    }
                    public func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        try container.encode(self.brand, forKey: .brand)
                        try container.encode(self.company, forKey: .company)
                    }
                }
                """
            }

            assertMacro {
                """
                @Codable
                internal struct A: Encodable {
                    let brand: Brand?
                    @OmitCoding
                    @CodingKey("_company")
                    let company: Company
                }
                """
            } expansion: {
                """
                internal struct A: Encodable {
                    let brand: Brand?
                    let company: Company
                }

                extension A: Decodable {
                    enum CodingKeys: String, CodingKey {
                        case brand
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        self.brand = try container.decodeIfPresent(Brand.self, forKey: .brand)
                    }
                }
                """
            }

            assertMacro {
                """
                @Codable
                public struct A {
                    var string: String { "" }
                    let company: Company
                }
                """
            } expansion: {
                """
                public struct A {
                    var string: String { "" }
                    let company: Company
                }

                extension A: Decodable, Encodable {
                    public enum CodingKeys: String, CodingKey {
                        case string
                        case company
                    }
                    public init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        self.company = try container.decode(Company.self, forKey: .company)
                    }
                    public func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        try container.encode(self.company, forKey: .company)
                    }
                }
                """
            }

            assertMacro {
                """
                @Codable
                public struct A {
                    var string1: String { "" }
                    var string2: String { "" }
                }
                """
            } expansion: {
                """
                public struct A {
                    var string1: String { "" }
                    var string2: String { "" }
                }

                extension A: Decodable, Encodable {
                    public enum CodingKeys: String, CodingKey {
                        case string1
                        case string2
                    }
                    public init(from decoder: Decoder) throws {
                    }
                    public func encode(to encoder: Encoder) throws {
                    }
                }
                """
            }
        }
    }

    func test_Encodable() {
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
                enum A {}
                """
            } diagnostics: {
                """
                @Encodable
                ┬─────────
                ╰─ 🛑 'Encodable' macro can only be applied to a struct or to a class
                enum A {}
                """
            }

            assertMacro {
                """
                @Encodable
                struct A: Encodable {
                    let brand: Brand
                    let company: Company
                }
                """
            } expansion: {
                """
                struct A: Encodable {
                    let brand: Brand
                    let company: Company
                }
                """
            }

            assertMacro {
                """
                @Encodable
                struct A: Decodable {
                    let brand: Brand
                    let company: Company
                }
                """
            } expansion: {
                """
                struct A: Decodable {
                    let brand: Brand
                    let company: Company
                }

                extension A: Encodable {
                    enum CodingKeys: String, CodingKey {
                        case brand
                        case company
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        try container.encode(self.brand, forKey: .brand)
                        try container.encode(self.company, forKey: .company)
                    }
                }
                """
            }

            assertMacro {
                """
                @Encodable
                struct A: Codable {
                    let brand: Brand
                    let company: Company
                }
                """
            } expansion: {
                """
                struct A: Codable {
                    let brand: Brand
                    let company: Company
                }
                """
            }

            assertMacro {
                """
                @Encodable
                struct A: Encodable, Decodable {
                    let brand: Brand
                    let company: Company
                }
                """
            } expansion: {
                """
                struct A: Encodable, Decodable {
                    let brand: Brand
                    let company: Company
                }
                """
            }

            assertMacro {
                """
                @Encodable
                private struct A {
                    let brand: Brand
                    @OmitCoding
                    let company: Company
                }
                """
            } expansion: {
                """
                private struct A {
                    let brand: Brand
                    let company: Company
                }

                extension A: Encodable {
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
                public struct A {
                    let brand: Brand
                    @CodingKey("_company")
                    let company: Company
                }
                """
            } expansion: {
                """
                public struct A {
                    let brand: Brand
                    let company: Company
                }

                extension A: Encodable {
                    public enum CodingKeys: String, CodingKey {
                        case brand
                        case company = "_company"
                    }
                    public func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        try container.encode(self.brand, forKey: .brand)
                        try container.encode(self.company, forKey: .company)
                    }
                }
                """
            }

            assertMacro {
                """
                @Encodable
                internal struct A: Encodable {
                    let brand: Brand?
                    @OmitCoding
                    @CodingKey("_company")
                    let company: Company
                }
                """
            } expansion: {
                """
                internal struct A: Encodable {
                    let brand: Brand?
                    let company: Company
                }
                """
            }
        }
    }

    func test_Decodable() {
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
                enum A {}
                """
            } diagnostics: {
                """
                @Decodable
                ┬─────────
                ╰─ 🛑 'Decodable' macro can only be applied to a struct or to a class
                enum A {}
                """
            }

            assertMacro {
                """
                @Decodable
                struct A: Encodable {
                    let brand: Brand
                    let company: Company
                }
                """
            } expansion: {
                """
                struct A: Encodable {
                    let brand: Brand
                    let company: Company
                }

                extension A: Decodable {
                    enum CodingKeys: String, CodingKey {
                        case brand
                        case company
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        self.brand = try container.decode(Brand.self, forKey: .brand)
                        self.company = try container.decode(Company.self, forKey: .company)
                    }
                }
                """
            }

            assertMacro {
                """
                @Decodable
                struct A: Decodable {
                    let brand: Brand
                    let company: Company
                }
                """
            } expansion: {
                """
                struct A: Decodable {
                    let brand: Brand
                    let company: Company
                }
                """
            }

            assertMacro {
                """
                @Decodable
                struct A: Codable {
                    let brand: Brand
                    let company: Company
                }
                """
            } expansion: {
                """
                struct A: Codable {
                    let brand: Brand
                    let company: Company
                }
                """
            }

            assertMacro {
                """
                @Decodable
                struct A: Encodable, Decodable {
                    let brand: Brand
                    let company: Company
                }
                """
            } expansion: {
                """
                struct A: Encodable, Decodable {
                    let brand: Brand
                    let company: Company
                }
                """
            }

            assertMacro {
                """
                @Decodable
                private struct A {
                    let brand: Brand
                    @OmitCoding
                    let company: Company
                }
                """
            } expansion: {
                """
                private struct A {
                    let brand: Brand
                    let company: Company
                }

                extension A: Decodable {
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
                public struct A {
                    let brand: Brand
                    @CodingKey("_company")
                    let company: Company
                }
                """
            } expansion: {
                """
                public struct A {
                    let brand: Brand
                    let company: Company
                }

                extension A: Decodable {
                    public enum CodingKeys: String, CodingKey {
                        case brand
                        case company = "_company"
                    }
                    public init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        self.brand = try container.decode(Brand.self, forKey: .brand)
                        self.company = try container.decode(Company.self, forKey: .company)
                    }
                }
                """
            }

            assertMacro {
                """
                @Decodable
                internal struct A: Encodable {
                    let brand: Brand?
                    @OmitCoding
                    let company: Company
                }
                """
            } expansion: {
                """
                internal struct A: Encodable {
                    let brand: Brand?
                    let company: Company
                }

                extension A: Decodable {
                    enum CodingKeys: String, CodingKey {
                        case brand
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        self.brand = try container.decodeIfPresent(Brand.self, forKey: .brand)
                    }
                }
                """
            }
        }
    }

    func test_playground() {
        withMacroTesting(
            isRecording: isRecording,
            macros: [
                "Codable": DecodableMacro.self,
                "OmitCoding": OmitCodingMacro.self,
                "CodingKey": CodingKeyMacro.self,
            ]
        ) {
            assertMacro {
                """
                @Codable
                struct A: Encodable {
                    @OmitCoding
                    @CodingKey("")
                    @available(*, iOS)
                    let company: Company
                }
                """
            } expansion: {
                """
                struct A: Encodable {
                    @available(*, iOS)
                    let company: Company
                }

                extension A: Decodable {
                    init(from decoder: Decoder) throws {
                    }
                }
                """
            }
        }
    }
}
