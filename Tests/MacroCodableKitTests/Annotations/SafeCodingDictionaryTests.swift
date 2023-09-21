//
//  SafeCodingDictionaryTests.swift
//
//
//  Created by Mikhail Maslo on 03.10.23.
//

import MacroCodableKit
import XCTest

final class SafeCodingDictionaryTests: XCTestCase {
    @Codable
    struct SafeCodingDictionary1: Equatable {
        let intByString: [String: Int]

        @CustomCoding(SafeDecoding)
        let safeIntByString: [String: Int]
    }

    @Codable
    struct SafeCodingDictionary2 {
        let stringByInt: [Int: String]

        @CustomCoding(SafeDecoding)
        let safeStringByInt: [Int: String]
    }

    @Codable
    struct SafeCodingDictionary3 {
        let intByString: [String: Int]

        @CustomCoding(SafeDecoding)
        let safeIntByString: [String: Int]?
    }

    func test_SafeCodingDictionary1_IntByString() throws {
        let json = """
        {
            "intByString": {
                "one": 1,
                "two": 2
            },
            "safeIntByString": {
                "three": 3,
                "four": "invalid"
            }
        }
        """
        let jsonData = Data(json.utf8)
        let decoded = try JSONDecoder().decode(SafeCodingDictionary1.self, from: jsonData)

        XCTAssertEqual(decoded.intByString["one"], 1)
        XCTAssertEqual(decoded.intByString["two"], 2)
        XCTAssertEqual(decoded.safeIntByString["three"], 3)
        XCTAssertEqual(decoded.safeIntByString.count, 1)
    }

    func test_SafeCodingDictionary2_StringByInt() throws {
        let json = """
        {
            "stringByInt": {
                "1": "one",
                "2": "two"
            },
            "safeStringByInt": {
                "3": "three",
                "4": false
            }
        }
        """
        let jsonData = Data(json.utf8)
        let decoded = try JSONDecoder().decode(SafeCodingDictionary2.self, from: jsonData)

        XCTAssertEqual(decoded.stringByInt[1], "one")
        XCTAssertEqual(decoded.stringByInt[2], "two")
        XCTAssertEqual(decoded.safeStringByInt[3], "three")
        XCTAssertEqual(decoded.safeStringByInt.count, 1)
    }

    func test_SafeCodingDictionary3_OptionalDict() throws {
        let json = """
        {
            "intByString": {
                "one": 1,
                "two": 2,
                "three": 3
            }
        }
        """
        let jsonData = Data(json.utf8)
        let decoded = try JSONDecoder().decode(SafeCodingDictionary3.self, from: jsonData)

        XCTAssertEqual(decoded.intByString["one"], 1)
        XCTAssertEqual(decoded.intByString["two"], 2)
        XCTAssertEqual(decoded.intByString["three"], 3)
        XCTAssertNil(decoded.safeIntByString)
    }

    func test_DictionaryDecoderRespectsDecodingStrategy() throws {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        let sut = SafeCodingDictionary1(
            intByString: [
                "snake_case.with.dots_99.and_numbers": 1,
                "dots.and_2.00.1_numbers": 2,
                "key.1": 3,
                "normal key": 4,
                "another_key": 5,
            ],
            safeIntByString: [
                "snake_case.with.dots_99.and_numbers": 1,
                "dots.and_2.00.1_numbers": 2,
                "key.1": 3,
                "normal key": 4,
                "another_key": 5,
            ]
        )

        let result = try decoder.decode(SafeCodingDictionary1.self, from: encoder.encode(sut))

        XCTAssertEqual(result.intByString, sut.intByString)
        XCTAssertEqual(result.safeIntByString, sut.safeIntByString)
    }
}
