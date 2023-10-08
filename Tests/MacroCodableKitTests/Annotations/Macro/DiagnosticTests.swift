//
//  File.swift
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

final class DiagnosticTests: XCTestCase {
    func testDuplicatedAnnotations() {
        withMacroTesting(
            isRecording: isRecording,
            macros: [
                "Codable": CodableMacro.self,
                "OmitCoding": OmitCodingMacro.self,
                "CodingKey": CodingKeyMacro.self,
                "ValueStrategy": ValueStrategyMacro.self,
                "DefaultValue": DefaultValueMacro.self,
                "CustomCoding": CustomCodingMacro.self,
            ]
        ) {
            assertMacro {
                """
                @Codable
                struct Example\(sutSuffix) {
                    @OmitCoding
                    @OmitCoding
                    let a: Int
                }
                """
            } diagnostics: {
                """
                @Codable
                struct Example__testing__ {
                    @OmitCoding
                    ╰─ 🛑 '@Omitcoding' attribute has been applied more than once. Redundant attribute applications have no effect on the generated code and may cause confusion.
                    @OmitCoding
                    let a: Int
                }
                """
            }

            assertMacro {
                """
                @Codable
                struct Example\(sutSuffix) {
                    @CodingKey("_a")
                    @CodingKey("_a")
                    let a: Int
                }
                """
            } diagnostics: {
                """
                @Codable
                struct Example__testing__ {
                    @CodingKey("_a")
                    ╰─ 🛑 '@Codingkey' attribute has been applied more than once. Redundant attribute applications have no effect on the generated code and may cause confusion.
                    @CodingKey("_a")
                    let a: Int
                }
                """
            }

            assertMacro {
                """
                @Codable
                struct Example\(sutSuffix) {
                    @ValueStrategy(Base64Data)
                    @ValueStrategy(Base64Data)
                    let string: String
                }
                """
            } diagnostics: {
                """
                @Codable
                struct Example__testing__ {
                    @ValueStrategy(Base64Data)
                    ╰─ 🛑 '@Valuestrategy' attribute has been applied more than once. Redundant attribute applications have no effect on the generated code and may cause confusion.
                    @ValueStrategy(Base64Data)
                    let string: String
                }
                """
            }

            assertMacro {
                """
                @Codable
                struct Example\(sutSuffix) {
                    @DefaultValue(BoolTrue)
                    @DefaultValue(BoolFalse)
                    let bool: Bool
                }
                """
            } diagnostics: {
                """
                @Codable
                struct Example__testing__ {
                    @DefaultValue(BoolTrue)
                    ╰─ 🛑 '@Defaultvalue' attribute has been applied more than once. Redundant attribute applications have no effect on the generated code and may cause confusion.
                    @DefaultValue(BoolFalse)
                    let bool: Bool
                }
                """
            }

            assertMacro {
                """
                @Codable
                struct Example\(sutSuffix) {
                    @CustomCoding(SafeDecoding)
                    @CustomCoding(SafeDecoding)
                    let array: [Bool]
                }
                """
            } diagnostics: {
                """
                @Codable
                struct Example__testing__ {
                    @CustomCoding(SafeDecoding)
                    ╰─ 🛑 '@Customcoding' attribute has been applied more than once. Redundant attribute applications have no effect on the generated code and may cause confusion.
                    @CustomCoding(SafeDecoding)
                    let array: [Bool]
                }
                """
            }
        }
    }

    func test_unsupportedAnnotations() {
        withMacroTesting(
            isRecording: isRecording,
            macros: [
                "Codable": CodableMacro.self,
            ]
        ) {
            assertMacro {
                """
                @Codable
                struct Example\(sutSuffix) {
                    let a, b: Int
                }
                """
            } diagnostics: {
                """
                @Codable
                struct Example__testing__ {
                    let a, b: Int
                    ┬────────────
                    ╰─ 🛑 '@Codable' macro is only applicable to declarations with an identifier followed by a type
                }
                """
            }

            assertMacro {
                """
                @Codable
                struct Example\(sutSuffix) {
                    let a: Int, b: Int
                }
                """
            } diagnostics: {
                """
                @Codable
                struct Example__testing__ {
                    let a: Int, b: Int
                    ┬─────────────────
                    ╰─ 🛑 '@Codable' macro is not applicable to compound declarations, declare each variable on a new line
                }
                """
            }

            assertMacro {
                """
                @Codable
                struct Example\(sutSuffix) {
                    @DefaultValue(IntZero)
                    var a: Int { 0 }
                }
                """
            } diagnostics: {
                """
                @Codable
                struct Example__testing__ {
                    @DefaultValue(IntZero)
                    ╰─ 🛑 '@Codable' macro is only applicable to stored properties declared with an identifier followed by a type, example: `let variable: Int`
                    var a: Int { 0 }
                }
                """
            }
        }
    }
}
