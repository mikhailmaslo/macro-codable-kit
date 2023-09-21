//
//  OneOfMacroDecodingTests.swift
//
//
//  Created by Mikhail Maslo on 23.09.23.
//

import MacroCodableKit
import XCTest

final class OneOfMacroDecodingTests: XCTestCase {
    func testValidPlainOneOfTestCases() throws {
        let testCases: [(String, PlainOneOf)] = [
            ("{\"int\": 1}", .int(1)),
            ("{\"boolean\": true}", .boolean(true)),
            ("{\"string\": \"Hello world\"}", .string("Hello world")),
        ]
        for testCase in testCases {
            guard let data = testCase.0.data(using: .utf8) else {
                XCTFail("Couldn't get data from \(testCase.0)")
                continue
            }

            XCTAssertEqual(try JSONDecoder().decode(PlainOneOf.self, from: data), testCase.1)
            XCTAssertEqual(try JSONDecoder().decode(PlainOneOf.self, from: try JSONEncoder().encode(testCase.1)), testCase.1)
        }
    }

    func testInvalidPlainOneOfTestCase() {
        let json = "{\"int\": true}"
        do {
            _ = try json.data(using: .utf8).flatMap { try JSONDecoder().decode(PlainOneOf.self, from: $0) }
            XCTFail("Shouldn't decode invalid \(json)")
        } catch {}
    }

    func testValidNestedOneOfTestCases() throws {
        let testCases: [(String, NestedOneOf)] = [
            ("{\"plain\": {\"boolean\": true}}", .plain(.boolean(true))),
        ]
        for testCase in testCases {
            guard let data = testCase.0.data(using: .utf8) else {
                XCTFail("Couldn't get data from \(testCase.0)")
                continue
            }

            XCTAssertEqual(try JSONDecoder().decode(NestedOneOf.self, from: data), testCase.1)
            XCTAssertEqual(try JSONDecoder().decode(NestedOneOf.self, from: try JSONEncoder().encode(testCase.1)), testCase.1)
        }
    }

    func testInvalidNestedOneOfTestCase() {
        let json = "{\"plain\": true}"
        do {
            _ = try json.data(using: .utf8).flatMap { try JSONDecoder().decode(PlainOneOf.self, from: $0) }
            XCTFail("Shouldn't decode invalid \(json)")
        } catch {}
    }
}

@OneOfCodable
private enum PlainOneOf: Equatable {
    case int(Int)
    case boolean(Bool)
    case string(String)
}

@OneOfCodable
private enum NestedOneOf: Equatable {
    case plain(PlainOneOf)
    case int(Int)
    case boolean(Bool)
    case string(String)
}
