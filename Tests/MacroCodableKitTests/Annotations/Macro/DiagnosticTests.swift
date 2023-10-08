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
                struct Example {
                    @OmitCoding
                    @OmitCoding
                    let a: Int
                }
                """
            } diagnostics: {
                """
                @Codable
                struct Example {
                    @OmitCoding
                    ╰─ 🛑 The attribute '@Omitcoding' has been applied more than once'. Redundant attribute applications have no effect on the generated code and may cause confusion.
                    @OmitCoding
                    let a: Int
                }
                """
            }

            assertMacro {
                """
                @Codable
                struct Example {
                    @CodingKey("_a")
                    @CodingKey("_a")
                    let a: Int
                }
                """
            } diagnostics: {
                """
                @Codable
                struct Example {
                    @CodingKey("_a")
                    ╰─ 🛑 The attribute '@Codingkey' has been applied more than once'. Redundant attribute applications have no effect on the generated code and may cause confusion.
                    @CodingKey("_a")
                    let a: Int
                }
                """
            }

            assertMacro {
                """
                @Codable
                struct Example {
                    @ValueStrategy(Base64Data)
                    @ValueStrategy(Base64Data)
                    let string: String
                }
                """
            } diagnostics: {
                """
                @Codable
                struct Example {
                    @ValueStrategy(Base64Data)
                    ╰─ 🛑 The attribute '@Valuestrategy' has been applied more than once'. Redundant attribute applications have no effect on the generated code and may cause confusion.
                    @ValueStrategy(Base64Data)
                    let string: String
                }
                """
            }

            assertMacro {
                """
                @Codable
                struct Example {
                    @DefaultValue(BoolTrue)
                    @DefaultValue(BoolFalse)
                    let bool: Bool
                }
                """
            } diagnostics: {
                """
                @Codable
                struct Example {
                    @DefaultValue(BoolTrue)
                    ╰─ 🛑 The attribute '@Defaultvalue' has been applied more than once'. Redundant attribute applications have no effect on the generated code and may cause confusion.
                    @DefaultValue(BoolFalse)
                    let bool: Bool
                }
                """
            }

            assertMacro {
                """
                @Codable
                struct Example {
                    @CustomCoding(SafeDecoding)
                    @CustomCoding(SafeDecoding)
                    let array: [Bool]
                }
                """
            } diagnostics: {
                """
                @Codable
                struct Example {
                    @CustomCoding(SafeDecoding)
                    ╰─ 🛑 The attribute '@Customcoding' has been applied more than once'. Redundant attribute applications have no effect on the generated code and may cause confusion.
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
                "Codable": CodableMacro.self
            ]
        ) {
            assertMacro {
                """
                @Codable
                struct Example {
                    let a, b: Int
                }
                """
            } diagnostics: {
                """
                @Codable
                struct Example {
                    let a, b: Int
                    ┬────────────
                    ╰─ 🛑 'Codable' macro is only applicable to declarations with an identifier followed by a type
                }
                """
            }

            assertMacro {
                """
                @Codable
                struct Example {
                    let a: Int, b: Int
                }
                """
            } diagnostics: {
                """
                @Codable
                struct Example {
                    let a: Int, b: Int
                    ┬─────────────────
                    ╰─ 🛑 'Codable' macro is not applicable to compound declarations, declare each variable on a new line
                }
                """
            }

            assertMacro {
                """
                @Codable
                struct Example {
                    @DefaultValue(IntZero)
                    var a: Int { 0 }
                }
                """
            } diagnostics: {
                """
                @Codable
                struct Example {
                    @DefaultValue(IntZero)
                    ╰─ 🛑 'Codable' macro is only applicable to stored properties declared with an identifier followed by a type, example: `let variable: Int`
                    var a: Int { 0 }
                }
                """
            }
        }
    }
}
