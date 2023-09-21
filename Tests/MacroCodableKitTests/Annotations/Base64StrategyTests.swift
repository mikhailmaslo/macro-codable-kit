//
//  Base64StrategyTests.swift
//
//
//  Created by Mikhail Maslo on 03.10.23.
//

import MacroCodableKit
import XCTest

final class Base64StrategyTests: XCTestCase {
    @Codable
    struct Base64Struct {
        @ValueStrategy(Base64Data)
        let data: Data
    }

    func test_Base64Struct() throws {
        let expectedResult = "Hello world!"
        let json = #"{"data":"SGVsbG8gd29ybGQh"}"#
        let jsonData = Data(json.utf8)
        let decoded = try JSONDecoder().decode(Base64Struct.self, from: jsonData)

        XCTAssertEqual(String(data: decoded.data, encoding: .utf8), expectedResult)
    }
}
