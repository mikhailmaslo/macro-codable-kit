//
//  ValueStrategyMacroTests.swift
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

final class ValueStrategyMacroTests: XCTestCase {
    func test_ValueStrategy() {
        withMacroTesting(
            isRecording: isRecording,
            macros: [
                "Codable": CodableMacro.self,
                "ValueStrategy": ValueStrategyMacro.self,
            ]
        ) {
            assertMacro {
                """
                @Codable
                struct Base64Struct {
                    let data: Data

                    @ValueStrategy(Base64Data)
                    let data: Data

                    @ValueStrategy(Base64Data)
                    let data: Data?
                }
                """
            } expansion: {
                """
                struct Base64Struct {
                    let data: Data
                    let data: Data
                    let data: Data?
                }

                extension Base64Struct: Decodable, Encodable {
                    enum CodingKeys: String, CodingKey {
                        case data
                        case data
                        case data
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        self.data = try container.decode(Data.self, forKey: .data)
                        self.data = try CustomCodingDecoding.decode(
                            Data.self,
                            forKey: .data,
                            container: container,
                            strategy: Base64Data.self
                        )
                        self.data = try CustomCodingDecoding.decode(
                            Data?.self,
                            forKey: .data,
                            container: container,
                            strategy: Base64Data.self
                        )
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        try container.encode(self.data, forKey: .data)
                        try CustomCodingEncoding.encode(self.data, forKey: .data, container: &container, strategy: Base64Data.self)
                        try CustomCodingEncoding.encode(self.data, forKey: .data, container: &container, strategy: Base64Data.self)
                    }
                }
                """
            }
        }
    }
}
