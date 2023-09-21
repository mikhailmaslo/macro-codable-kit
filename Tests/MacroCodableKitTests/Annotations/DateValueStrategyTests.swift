//
//  DateValueStrategyTests.swift
//
//
//  Created by Mikhail Maslo on 03.10.23.
//

import Foundation
import MacroCodableKit
import XCTest

final class DateValueStrategyTests: XCTestCase {
    @Codable
    struct IOS8601DefaultExample {
        @ValueStrategy(ISO8601Default)
        let date: Date
    }

    func test_IOS8601DefaultExample() throws {
        // Prepare the JSON string with ISO 8601 formatted date
        let jsonString = #"{"date": "2023-10-03T10:15:30+00:00"}"#
        let jsonData = Data(jsonString.utf8)
        let expectedDate = Date(timeIntervalSince1970: 1_696_328_130.0)

        let decodedExample = try JSONDecoder().decode(IOS8601DefaultExample.self, from: jsonData)

        XCTAssertEqual(decodedExample.date, expectedDate)
    }

    @Codable
    struct ISO8601FullDateExample {
        @ValueStrategy(ISO8601WithFullDate)
        let date: Date
    }

    func test_ISO8601WithFullDateExample() throws {
        let jsonString = #"{"date": "2023-10-03"}"#
        let jsonData = Data(jsonString.utf8)
        let expectedDate = Date(timeIntervalSince1970: 1_696_291_200.0)

        let decodedExample = try JSONDecoder().decode(ISO8601FullDateExample.self, from: jsonData)
        XCTAssertEqual(decodedExample.date, expectedDate)
    }

    @Codable
    struct ISO8601FractionalSecondsExample {
        @ValueStrategy(ISO8601WithFractionalSeconds)
        let date: Date
    }

    func test_ISO8601WithFractionalSecondsExample() throws {
        let jsonString = #"{"date": "2023-10-03T10:15:30.123+00:00"}"#
        let jsonData = Data(jsonString.utf8)
        let expectedDate = Date(timeIntervalSince1970: 1_696_328_130.123)

        let decodedExample = try JSONDecoder().decode(ISO8601FractionalSecondsExample.self, from: jsonData)
        XCTAssertEqual(decodedExample.date, expectedDate)
    }

    @Codable
    struct RFC2822DateExample {
        @ValueStrategy(RFC2822Date)
        let date: Date
    }

    func test_RFC2822DateExample() throws {
        let jsonString = #"{"date": "Tue, 3 Oct 2023 10:15:30 GMT"}"#
        let jsonData = Data(jsonString.utf8)
        let expectedDate = Date(timeIntervalSince1970: 1_696_328_130.0)

        // Decode and validate
        let decodedExample = try JSONDecoder().decode(RFC2822DateExample.self, from: jsonData)
        XCTAssertEqual(decodedExample.date, expectedDate)
    }

    @Codable
    struct RFC3339DateExample {
        @ValueStrategy(RFC3339Date)
        let date: Date
    }

    func test_RFC3339DateExample() throws {
        let jsonString = #"{"date": "2023-10-03T10:15:30Z"}"#
        let jsonData = Data(jsonString.utf8)
        let expectedDate = Date(timeIntervalSince1970: 1_696_328_130.0)

        let decodedExample = try JSONDecoder().decode(RFC3339DateExample.self, from: jsonData)
        XCTAssertEqual(decodedExample.date, expectedDate)
    }

    @Codable
    struct YearMonthDayDateExample {
        @ValueStrategy(YearMonthDayDate)
        let date: Date
    }

    func test_YearMonthDayDateExample() throws {
        let jsonString = #"{"date": "2023-10-03"}"#
        let jsonData = Data(jsonString.utf8)
        let expectedDate = Date(timeIntervalSince1970: 1_696_291_200.0)

        let decodedExample = try JSONDecoder().decode(YearMonthDayDateExample.self, from: jsonData)
        XCTAssertEqual(decodedExample.date, expectedDate)
    }

    @Codable
    struct TimestampedDateExample {
        @ValueStrategy(TimestampedDate)
        let date: Date
    }

    func test_TimestampedDateExample_Double() throws {
        let jsonString = #"{"date": 1696291200.0}"#
        let jsonData = Data(jsonString.utf8)
        let expectedDate = Date(timeIntervalSince1970: 1_696_291_200.0)

        let decodedExample = try JSONDecoder().decode(TimestampedDateExample.self, from: jsonData)
        XCTAssertEqual(decodedExample.date, expectedDate)
    }

    func test_TimestampedDateExample_String() throws {
        let jsonString = #"{"date": "1696291200.0"}"#
        let jsonData = Data(jsonString.utf8)
        let expectedDate = Date(timeIntervalSince1970: 1_696_291_200.0)

        let decodedExample = try JSONDecoder().decode(TimestampedDateExample.self, from: jsonData)
        XCTAssertEqual(decodedExample.date, expectedDate)
    }

    @Codable
    struct TimestampedDateOptionalExample {
        @ValueStrategy(TimestampedDate)
        let date: Date?
    }

    func test_TimestampedDateOptionalExample() throws {
        let jsonString = #"{"date": "1696291200.0"}"#
        let jsonData = Data(jsonString.utf8)
        let expectedDate = Date(timeIntervalSince1970: 1_696_291_200.0)

        let decodedExample = try JSONDecoder().decode(TimestampedDateExample.self, from: jsonData)
        XCTAssertEqual(decodedExample.date, expectedDate)
    }
}
