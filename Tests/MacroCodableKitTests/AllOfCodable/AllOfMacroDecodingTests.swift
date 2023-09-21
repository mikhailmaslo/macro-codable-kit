//
//  AllOfMacroCodableTests.swift
//
//
//  Created by Mikhail Maslo on 23.09.23.
//

import MacroCodableKit
import XCTest

final class AllOfMacroCodableTests: XCTestCase {
    func testValidPlainAllOfTestCases() throws {
        let testCases: [(String, A)] = [
            (#"{ "int": 1, "boolean": true, "string": "some string", "anotherInt": 1 }"#, A(b: A.B(int: 1, boolean: true, string: "some string"), c: A.C(anotherInt: 1))),
        ]
        for testCase in testCases {
            guard let data = testCase.0.data(using: .utf8) else {
                XCTFail("Couldn't get data from \(testCase.0)")
                continue
            }

            XCTAssertEqual(try JSONDecoder().decode(A.self, from: data), testCase.1)
            XCTAssertEqual(try JSONDecoder().decode(A.self, from: try JSONEncoder().encode(testCase.1)), testCase.1)
        }
    }

    func testInvalidPlainAllOfTestCase() {
        let json = #"{ "int": 1, "boolean": true, "string": "some string" }"#
        do {
            _ = try json.data(using: .utf8).flatMap { try JSONDecoder().decode(A.self, from: $0) }
            XCTFail("Shouldn't decode invalid \(json)")
        } catch {}
    }
}

@AllOfCodable
private struct A: Equatable {
    struct B: Codable, Equatable {
        let int: Int
        let boolean: Bool
        let string: String
    }

    struct C: Codable, Equatable {
        let anotherInt: Int
    }

    let b: B
    let c: C
}
