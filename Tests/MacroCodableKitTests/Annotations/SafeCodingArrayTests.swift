//
//  SafeCodingArrayTests.swift
//
//
//  Created by Mikhail Maslo on 03.10.23.
//

import MacroCodableKit
import XCTest

final class SafeCodingArrayTests: XCTestCase {
    @Codable
    struct SafeCodingArray1: Equatable {
        let strings: [String]

        @CustomCoding(SafeDecoding)
        let safeStrings: [String]
    }

    @Codable
    struct SafeCodingArray2: Equatable {
        @CustomCoding(SafeDecoding)
        let safeStrings: [String]?
    }

    func test_SafeCodingArray1_DiscardsInvalidArrayElements() throws {
        let json = """
        {
            "strings": ["a", "b", "c"],
            "safeStrings": ["a", true, "b", "c", 0]
        }
        """
        let jsonData = Data(json.utf8)
        let decoded = try JSONDecoder().decode(SafeCodingArray1.self, from: jsonData)

        XCTAssertEqual(decoded.strings, decoded.safeStrings)
    }

    func test_SafeCodingArray2_SafelyDecodsAbsentArray() throws {
        let json = "{}"
        let jsonData = Data(json.utf8)
        let decoded = try JSONDecoder().decode(SafeCodingArray2.self, from: jsonData)

        XCTAssertNil(decoded.safeStrings)
    }
}
