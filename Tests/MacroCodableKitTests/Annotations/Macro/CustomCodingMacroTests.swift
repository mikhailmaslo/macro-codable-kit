//
//  CustomCodingMacroTests.swift
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

final class CustomCodingMacroTests: XCTestCase {
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
                struct SafeCodingArray1: Equatable {
                    let strings: [String]

                    @CustomCoding(SafeDecoding)
                    let safeStrings: [String]
                }
                """
            } expansion: {
                """
                struct SafeCodingArray1: Equatable {
                    let strings: [String]

                    @CustomCoding(SafeDecoding)
                    let safeStrings: [String]
                }

                extension SafeCodingArray1: Decodable, Encodable {
                    enum CodingKeys: String, CodingKey {
                        case strings
                        case safeStrings
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        self.strings = try container.decode([String].self, forKey: .strings)
                        self.safeStrings = try CustomCodingDecoding.safeDecoding(
                            [String].self,
                            forKey: .safeStrings,
                            container: container
                        )
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        try container.encode(self.strings, forKey: .strings)
                        try CustomCodingEncoding.safeDecoding(self.safeStrings, forKey: .safeStrings, container: &container)
                    }
                }
                """
            }

            assertMacro {
                """
                @Codable
                struct SafeCodingArray2: Equatable {
                    @CustomCoding(SafeDecoding)
                    let safeStrings: [String]?
                }
                """
            } expansion: {
                """
                struct SafeCodingArray2: Equatable {
                    @CustomCoding(SafeDecoding)
                    let safeStrings: [String]?
                }

                extension SafeCodingArray2: Decodable, Encodable {
                    enum CodingKeys: String, CodingKey {
                        case safeStrings
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        self.safeStrings = try CustomCodingDecoding.safeDecoding(
                            [String]?.self,
                            forKey: .safeStrings,
                            container: container
                        )
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        try CustomCodingEncoding.safeDecoding(self.safeStrings, forKey: .safeStrings, container: &container)
                    }
                }
                """
            }

            assertMacro {
                """
                @Codable
                struct SafeCodingDictionary2 {
                    let stringByInt: [Int: String]

                    @CustomCoding(SafeDecoding)
                    let safeStringByInt: [Int: String]
                }
                """
            } expansion: {
                """
                struct SafeCodingDictionary2 {
                    let stringByInt: [Int: String]

                    @CustomCoding(SafeDecoding)
                    let safeStringByInt: [Int: String]
                }

                extension SafeCodingDictionary2: Decodable, Encodable {
                    enum CodingKeys: String, CodingKey {
                        case stringByInt
                        case safeStringByInt
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        self.stringByInt = try container.decode([Int: String].self, forKey: .stringByInt)
                        self.safeStringByInt = try CustomCodingDecoding.safeDecoding(
                            [Int: String].self,
                            forKey: .safeStringByInt,
                            container: container
                        )
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        try container.encode(self.stringByInt, forKey: .stringByInt)
                        try CustomCodingEncoding.safeDecoding(self.safeStringByInt, forKey: .safeStringByInt, container: &container)
                    }
                }
                """
            }

            assertMacro {
                """
                @Codable
                struct SafeCodingDictionary3 {
                    let intByString: [String: Int]

                    @CustomCoding(SafeDecoding)
                    let safeIntByString: [String: Int]?
                }
                """
            } expansion: {
                """
                struct SafeCodingDictionary3 {
                    let intByString: [String: Int]

                    @CustomCoding(SafeDecoding)
                    let safeIntByString: [String: Int]?
                }

                extension SafeCodingDictionary3: Decodable, Encodable {
                    enum CodingKeys: String, CodingKey {
                        case intByString
                        case safeIntByString
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        self.intByString = try container.decode([String: Int].self, forKey: .intByString)
                        self.safeIntByString = try CustomCodingDecoding.safeDecoding(
                            [String: Int]?.self,
                            forKey: .safeIntByString,
                            container: container
                        )
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        try container.encode(self.intByString, forKey: .intByString)
                        try CustomCodingEncoding.safeDecoding(self.safeIntByString, forKey: .safeIntByString, container: &container)
                    }
                }
                """
            }

            assertMacro {
                """
                @Codable
                struct SomeTypeCustomCoding {
                    @CustomCoding(XXXX)
                    let someType: SomeType?
                }
                """
            } expansion: {
                """
                struct SomeTypeCustomCoding {
                    @CustomCoding(XXXX)
                    let someType: SomeType?
                }

                extension SomeTypeCustomCoding: Decodable, Encodable {
                    enum CodingKeys: String, CodingKey {
                        case someType
                    }
                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        self.someType = try CustomCodingDecoding.xXXX(SomeType?.self, forKey: .someType, container: container)
                    }
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        try CustomCodingEncoding.xXXX(self.someType, forKey: .someType, container: &container)
                    }
                }
                """
            }
        }
    }
}
