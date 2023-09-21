//
//  DefaultValueMacroTests.swift
//
//
//  Created by Mikhail Maslo on 01.10.23.
//

import Macro
import MacroTesting
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

private let isRecording = false

final class DefaultValueMacroTests: XCTestCase {
    func test_DefaultValue() {
        withMacroTesting(
            isRecording: isRecording,
            macros: [
                "Codable": CodableMacro.self,
                "DefaultValue": DefaultValueMacro.self,
            ]
        ) {
            assertMacro {
                """
                @Codable
                struct DefaultValueBool {
                    let boolean1: Bool

                    @DefaultValue(BoolFalse)
                    let boolean2: Bool

                    @DefaultValue(BoolTrue)
                    let boolean3: Bool

                    @DefaultValue(BoolTrue)
                    let boolean4: Bool?

                    let boolean5: Bool?
                }
                """
            } matches: {
                """
                struct DefaultValueBool {
                    let boolean1: Bool
                    let boolean2: Bool
                    let boolean3: Bool
                    let boolean4: Bool?

                    let boolean5: Bool?
                }

                extension DefaultValueBool: Decodable, Encodable {
                    enum CodingKeys: String, CodingKey {
                        case boolean1
                        case boolean2
                        case boolean3
                        case boolean4
                        case boolean5
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        self.boolean1 = try container.decode(Bool.self, forKey: .boolean1)
                        self.boolean2 = try CustomCodingDecoding.decode(
                            Bool.self,
                            forKey: .boolean2,
                            container: container,
                            provider: BoolFalse.self
                        )
                        self.boolean3 = try CustomCodingDecoding.decode(
                            Bool.self,
                            forKey: .boolean3,
                            container: container,
                            provider: BoolTrue.self
                        )
                        self.boolean4 = try CustomCodingDecoding.decode(
                            Bool?.self,
                            forKey: .boolean4,
                            container: container,
                            provider: BoolTrue.self
                        )
                        self.boolean5 = try container.decodeIfPresent(Bool.self, forKey: .boolean5)
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        try container.encode(self.boolean1, forKey: .boolean1)
                        try container.encode(self.boolean2, forKey: .boolean2)
                        try container.encode(self.boolean3, forKey: .boolean3)
                        try container.encodeIfPresent(self.boolean4, forKey: .boolean4)
                        try container.encodeIfPresent(self.boolean5, forKey: .boolean5)
                    }
                }
                """
            }

            assertMacro {
                """
                @Codable
                struct DefaultValueInt {
                    let int1: Int

                    @DefaultValue(IntZero)
                    let int2: Int

                    @DefaultValue(IntZero)
                    let int3: Int?

                    let int4: Int?
                }
                """
            } matches: {
                """
                struct DefaultValueInt {
                    let int1: Int
                    let int2: Int
                    let int3: Int?

                    let int4: Int?
                }

                extension DefaultValueInt: Decodable, Encodable {
                    enum CodingKeys: String, CodingKey {
                        case int1
                        case int2
                        case int3
                        case int4
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        self.int1 = try container.decode(Int.self, forKey: .int1)
                        self.int2 = try CustomCodingDecoding.decode(
                            Int.self,
                            forKey: .int2,
                            container: container,
                            provider: IntZero.self
                        )
                        self.int3 = try CustomCodingDecoding.decode(
                            Int?.self,
                            forKey: .int3,
                            container: container,
                            provider: IntZero.self
                        )
                        self.int4 = try container.decodeIfPresent(Int.self, forKey: .int4)
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        try container.encode(self.int1, forKey: .int1)
                        try container.encode(self.int2, forKey: .int2)
                        try container.encodeIfPresent(self.int3, forKey: .int3)
                        try container.encodeIfPresent(self.int4, forKey: .int4)
                    }
                }
                """
            }

            assertMacro {
                """
                @Codable
                struct A {
                    let int1: Bool

                    @DefaultValue(IntZero)
                    let int2: Bool

                    @DefaultValue(EmptyString)
                    let string: String
                }
                """
            } matches: {
                """
                struct A {
                    let int1: Bool
                    let int2: Bool
                    let string: String
                }

                extension A: Decodable, Encodable {
                    enum CodingKeys: String, CodingKey {
                        case int1
                        case int2
                        case string
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        self.int1 = try container.decode(Bool.self, forKey: .int1)
                        self.int2 = try CustomCodingDecoding.decode(
                            Bool.self,
                            forKey: .int2,
                            container: container,
                            provider: IntZero.self
                        )
                        self.string = try CustomCodingDecoding.decode(
                            String.self,
                            forKey: .string,
                            container: container,
                            provider: EmptyString.self
                        )
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        try container.encode(self.int1, forKey: .int1)
                        try container.encode(self.int2, forKey: .int2)
                        try container.encode(self.string, forKey: .string)
                    }
                }
                """
            }
        }
    }
}
