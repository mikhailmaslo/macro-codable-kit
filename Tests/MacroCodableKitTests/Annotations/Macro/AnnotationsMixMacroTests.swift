//
//  AnnotationsMixMacroTests.swift
//
//
//  Created by Mikhail Maslo on 03.10.23.
//

import Macro
import MacroTesting
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

private let isRecording = false

final class AnnotationsMixMacroTests: XCTestCase {
    func test_DefaultValueAndValueStrategy() {
        withMacroTesting(
            isRecording: isRecording,
            macros: [
                "Codable": CodableMacro.self,
                "DefaultValue": DefaultValueMacro.self,
                "ValueStrategy": ValueStrategyMacro.self,
            ]
        ) {
            assertMacro {
                """
                @Codable
                struct DefaultValueBool {
                    @ValueStrategy(SomeBoolStrategy)
                    @DefaultValue(BoolFalse)
                    let boolean1: Bool

                    @ValueStrategy(SomeBoolStrategy)
                    @DefaultValue(BoolFalse)
                    let boolean2: Bool?
                }
                """
            } matches: {
                """
                struct DefaultValueBool {
                    let boolean1: Bool
                    let boolean2: Bool?
                }

                extension DefaultValueBool: Decodable, Encodable {
                    enum CodingKeys: String, CodingKey {
                        case boolean1
                        case boolean2
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        self.boolean1 = try CustomCodingDecoding.decode(
                            Bool.self,
                            forKey: .boolean1,
                            container: container,
                            strategy: SomeBoolStrategy.self,
                            provider: BoolFalse.self
                        )
                        self.boolean2 = try CustomCodingDecoding.decode(
                            Bool?.self,
                            forKey: .boolean2,
                            container: container,
                            strategy: SomeBoolStrategy.self,
                            provider: BoolFalse.self
                        )
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        try CustomCodingEncoding.encode(
                            self.boolean1,
                            forKey: .boolean1,
                            container: &container,
                            strategy: SomeBoolStrategy.self
                        )
                        try CustomCodingEncoding.encode(
                            self.boolean2,
                            forKey: .boolean2,
                            container: &container,
                            strategy: SomeBoolStrategy.self
                        )
                    }
                }
                """
            }
        }
    }
}
