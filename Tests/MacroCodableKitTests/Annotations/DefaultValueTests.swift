//
//  DefaultValueTests.swift
//
//
//  Created by Mikhail Maslo on 03.10.23.
//

import MacroCodableKit
import XCTest

final class DefaultValueTests: XCTestCase {
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

    @Codable
    struct DefaultValueInt {
        let int1: Int

        @DefaultValue(IntZero)
        let int2: Int

        @DefaultValue(IntZero)
        let int3: Int?

        let int4: Int?
    }

    @Codable
    struct DefaultValueDouble {
        let double1: Double

        @DefaultValue(DoubleZero)
        let double2: Double

        @DefaultValue(DoubleZero)
        let double3: Double?

        let double4: Double?
    }

    func test_DefaultValueBool() throws {
        let json = #"{"boolean1":true, "boolean2": 1234}"#
        let jsonData = Data(json.utf8)
        let decoded = try JSONDecoder().decode(DefaultValueBool.self, from: jsonData)

        XCTAssertTrue(decoded.boolean1)
        XCTAssertFalse(decoded.boolean2)
        XCTAssertTrue(decoded.boolean3)
        XCTAssertEqual(decoded.boolean4, true)
        XCTAssertNil(decoded.boolean5)
    }

    func test_DefaultValueInt() throws {
        let json = #"{"int1":100, "int2": true}"#
        let jsonData = Data(json.utf8)
        let decoded = try JSONDecoder().decode(DefaultValueInt.self, from: jsonData)

        XCTAssertEqual(decoded.int1, 100)
        XCTAssertEqual(decoded.int2, 0)
        XCTAssertEqual(decoded.int3, 0)
        XCTAssertNil(decoded.int4)
    }

    func test_DefaultValueDouble() throws {
        let json = #"{"double1":10.15, "double2": true}"#
        let jsonData = Data(json.utf8)
        let decoded = try JSONDecoder().decode(DefaultValueDouble.self, from: jsonData)

        XCTAssertEqual(decoded.double1, 10.15)
        XCTAssertEqual(decoded.double2, 0)
        XCTAssertEqual(decoded.double3, 0)
    }
}
