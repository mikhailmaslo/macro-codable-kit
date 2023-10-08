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
                enum NotApplicable\(sutSuffix) {}
                """
            } diagnostics: {
                """
                @AllOfEncodable
                ╰─ 🛑 '@AllOfEncodable' macro can only be applied to a struct
                enum NotApplicable__testing__ {}
                """
            }

            assertMacro {
                """
                @AllOfEncodable
                class NotApplicable\(sutSuffix) {}
                """
            } diagnostics: {
                """
                @AllOfEncodable
                ╰─ 🛑 '@AllOfEncodable' macro can only be applied to a struct
                class NotApplicable__testing__ {}
                """
            }

            assertMacro {
                """
                @AllOfEncodable
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

                extension Example__testing__: Encodable {
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
                struct NoCodableExample\(sutSuffix) {
                    let brand: Brand
                }

                @AllOfEncodable
                struct OnlyEncodableExample\(sutSuffix): Encodable {
                    let brand: Brand
                }

                @AllOfEncodable
                struct OnlyDecodableExample\(sutSuffix): Decodable {
                    let brand: Brand
                }

                @AllOfEncodable
                struct CodableExample\(sutSuffix): Codable {
                    let brand: Brand
                }
                """
            } diagnostics: {
                """
                @AllOfEncodable
                struct NoCodableExample__testing__ {
                    let brand: Brand
                }

                @AllOfEncodable
                ╰─ ⚠️ '@AllOfEncodable' macro has not effect since 'OnlyEncodableExample__testing__' already conformes to ["Encodable"]. Consider removing '@AllOfEncodable'
                struct OnlyEncodableExample__testing__: Encodable {
                    let brand: Brand
                }

                @AllOfEncodable
                struct OnlyDecodableExample__testing__: Decodable {
                    let brand: Brand
                }

                @AllOfEncodable
                ╰─ ⚠️ '@AllOfEncodable' macro has not effect since 'CodableExample__testing__' already conformes to ["Encodable"]. Consider removing '@AllOfEncodable'
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
                    func encode(to encoder: Encoder) throws {
                        try self.brand.encode(to: encoder)
                    }
                }

                extension OnlyDecodableExample__testing__: Encodable {
                    func encode(to encoder: Encoder) throws {
                        try self.brand.encode(to: encoder)
                    }
                }
                """
            }

            assertMacro {
                """
                @AllOfEncodable
                struct Empty1\(sutSuffix) {
                    @OmitCoding
                    let brand: Brand
                }

                @AllOfEncodable
                struct Empty2\(sutSuffix) {
                }
                """
            } expansion: {
                """
                struct Empty1__testing__ {
                    let brand: Brand
                }
                struct Empty2__testing__ {
                }

                extension Empty1__testing__: Encodable {
                    func encode(to encoder: Encoder) throws {
                    }
                }

                extension Empty2__testing__: Encodable {
                    func encode(to encoder: Encoder) throws {
                    }
                }
                """
            }

            assertMacro {
                """
                @AllOfEncodable
                struct NoPublicCodable1\(sutSuffix) {
                    let brand: Brand
                }

                @AllOfEncodable
                private struct NoPublicCodable2\(sutSuffix) {
                    let brand: Brand
                }

                @AllOfEncodable
                internal struct NoPublicCodable3\(sutSuffix) {
                    let brand: Brand
                }

                @AllOfEncodable
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
                    func encode(to encoder: Encoder) throws {
                        try self.brand.encode(to: encoder)
                    }
                }

                extension NoPublicCodable2__testing__: Encodable {
                    func encode(to encoder: Encoder) throws {
                        try self.brand.encode(to: encoder)
                    }
                }

                extension NoPublicCodable3__testing__: Encodable {
                    func encode(to encoder: Encoder) throws {
                        try self.brand.encode(to: encoder)
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
