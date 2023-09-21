//
//  AnnotationTests.swift
//
//
//  Created by Mikhail Maslo on 03.10.23.
//

import Foundation
import MacroCodableKit
import XCTest

final class AnnotationTests: XCTestCase {
    @Codable
    struct OmitCodingExample {
        @OmitCoding
        var a: Int?
        let b: Int
    }

    @Codable
    struct CodingKeyExample {
        @CodingKey("aaa")
        let a: Int
    }

    func test_OmitCoding() throws {
        let encodedA = try JSONEncoder().encode(OmitCodingExample(a: 0, b: 1))
        let json = try JSONSerialization.jsonObject(with: encodedA) as? [String: Any]
        XCTAssertEqual(json?["a"] as? Int, nil)
        XCTAssertEqual(json?["b"] as? Int, 1)
    }

    func test_CodingKey() throws {
        let json = #"{"aaa": 100}"#.data(using: .utf8)
        let decoded = try JSONDecoder().decode(CodingKeyExample.self, from: json!)

        XCTAssertEqual(decoded.a, 100)
    }

    final class DoubleStringStrategy: ValueCodableStrategy {
        typealias Value = String

        static func decode(from decoder: Decoder) throws -> String {
            let container = try decoder.singleValueContainer()
            let string = try container.decode(Value.self)
            return string + string
        }

        static func encode(value: String, to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(value)
        }
    }

    @Codable
    struct DoubleStringExample {
        @DefaultValue(EmptyString)
        @ValueStrategy(AnnotationTests.DoubleStringStrategy)
        let string1: String

        @DefaultValue(EmptyString)
        @ValueStrategy(AnnotationTests.DoubleStringStrategy)
        let string2: String
    }

    func test_DoubleStringStrategy() throws {
        let json = #"{"string1": "Hello"}"#
        let jsonData = Data(json.utf8)
        let expectedString = "HelloHello"

        let decoded = try JSONDecoder().decode(DoubleStringExample.self, from: jsonData)

        XCTAssertEqual(decoded.string1, expectedString, "Expected applied DoubleStringStrategy")
        XCTAssertEqual(decoded.string2, "", "Expected default to be an empty string")
    }

    final class NestedDoubleStringStrategy: ValueCodableStrategy {
        typealias Value = NestedDoubleStringExample.Nested

        static func decode(from decoder: Decoder) throws -> Value {
            let container = try decoder.singleValueContainer()
            let nested = try container.decode(Value.self)
            return Value(value: nested.value + nested.value)
        }

        static func encode(value: Value, to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(value)
        }
    }

    final class Nested123DefaultValueProvider: DefaultValueProvider {
        static var defaultValue: NestedDoubleStringExample.Nested {
            NestedDoubleStringExample.Nested(value: "123")
        }
    }

    @Codable
    struct NestedDoubleStringExample {
        @Codable
        struct Nested: Equatable {
            let value: String
        }

        @DefaultValue(AnnotationTests.Nested123DefaultValueProvider)
        @ValueStrategy(AnnotationTests.NestedDoubleStringStrategy)
        let n1: Nested

        @DefaultValue(AnnotationTests.Nested123DefaultValueProvider)
        @ValueStrategy(AnnotationTests.NestedDoubleStringStrategy)
        let n2: Nested
    }

    func test_NestedDoubleStringExample() throws {
        let json = #"{"n1": { "value": "Hello" } }"#
        let jsonData = Data(json.utf8)
        let expectedNested = NestedDoubleStringExample.Nested(value: "HelloHello")

        let decoded = try JSONDecoder().decode(NestedDoubleStringExample.self, from: jsonData)

        XCTAssertEqual(decoded.n1, expectedNested, "Expected applied NestedDoubleStringStrategy")
        XCTAssertEqual(decoded.n2.value, "123", "Expected default to be an 123 as in Nested123DefaultValueProvider")
    }

    @Codable
    struct TwiceExample: Equatable {
        @CustomCoding(Twice)
        var int: Int

        @CustomCoding(Twice)
        var string: String
    }

    func test_TwiceExample() throws {
        let json = #"{"string": "Hello", "int": 10}"#
        let jsonData = Data(json.utf8)
        let expected = TwiceExample(int: 20, string: "HelloHello")

        let decoded = try JSONDecoder().decode(TwiceExample.self, from: jsonData)

        XCTAssertEqual(decoded, expected)
    }
}

// MARK: - Twice

struct Twice: CustomDecodingName {}

extension CustomCodingDecoding {
    static func twice<K>(
        _: String.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>
    ) throws -> String {
        let result = try container.decode(String.self, forKey: key)
        return result + result
    }

    static func twice<K>(
        _: Int.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>
    ) throws -> Int {
        let result = try container.decode(Int.self, forKey: key)
        return result * 2
    }

    // We don't implement optional handling
}

public extension CustomCodingEncoding {
    // Handle all types the same way

    static func twice<K, Element: Encodable>(
        _ value: Element,
        forKey key: KeyedEncodingContainer<K>.Key,
        container: inout KeyedEncodingContainer<K>
    ) throws {
        try container.encode(value, forKey: key)
    }
}
