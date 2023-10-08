//
//  AllOfEncodableMacroTests.swift
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

final class AllOfEncodableMacroTests: XCTestCase {
    func test() throws {
        withMacroTesting(
            isRecording: isRecording,
            macros: [
                "AllOfEncodable": AllOfEncodableMacro.self,
                "OmitCoding": OmitCodingMacro.self,
            ]
        ) {
            assertMacro {
                """
                @AllOfEncodable
                enum NotApplicable {}
                """
            } diagnostics: {
                """
                @AllOfEncodable
                ╰─ 🛑 'AllOfEncodable' macro can only be applied to a struct
                enum NotApplicable {}
                """
            }

            assertMacro {
                """
                @AllOfEncodable
                class NotApplicable {}
                """
            } diagnostics: {
                """
                @AllOfEncodable
                ╰─ 🛑 'AllOfEncodable' macro can only be applied to a struct
                class NotApplicable {}
                """
            }

            assertMacro {
                """
                @AllOfEncodable
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

                extension Example: Encodable {
                    func encode(to encoder: Encoder) throws {
                        try self.brand.encodeIfPresent(to: encoder)
                        try self.company.encode(to: encoder)
                    }
                }
                """
            }

            assertMacro {
                """
                @AllOfEncodable
                struct NoCodableExample {
                    let brand: Brand
                }

                @AllOfEncodable
                struct OnlyEncodableExample: Encodable {
                    let brand: Brand
                }

                @AllOfEncodable
                struct OnlyDecodableExample: Decodable {
                    let brand: Brand
                }

                @AllOfEncodable
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
                    func encode(to encoder: Encoder) throws {
                        try self.brand.encode(to: encoder)
                    }
                }

                extension OnlyDecodableExample: Encodable {
                    func encode(to encoder: Encoder) throws {
                        try self.brand.encode(to: encoder)
                    }
                }
                """
            }

            assertMacro {
                """
                @AllOfEncodable
                struct Empty1 {
                    @OmitCoding
                    let brand: Brand
                }

                @AllOfEncodable
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

                extension Empty1: Encodable {
                    func encode(to encoder: Encoder) throws {
                    }
                }

                extension Empty2: Encodable {
                    func encode(to encoder: Encoder) throws {
                    }
                }
                """
            }

            assertMacro {
                """
                @AllOfEncodable
                struct NoPublicCodable1 {
                    let brand: Brand
                }

                @AllOfEncodable
                private struct NoPublicCodable2 {
                    let brand: Brand
                }

                @AllOfEncodable
                internal struct NoPublicCodable3 {
                    let brand: Brand
                }

                @AllOfEncodable
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
                    func encode(to encoder: Encoder) throws {
                        try self.brand.encode(to: encoder)
                    }
                }

                extension NoPublicCodable2: Encodable {
                    func encode(to encoder: Encoder) throws {
                        try self.brand.encode(to: encoder)
                    }
                }

                extension NoPublicCodable3: Encodable {
                    func encode(to encoder: Encoder) throws {
                        try self.brand.encode(to: encoder)
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
