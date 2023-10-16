//
//  YearMonthDayDateFormatterProvider.swift
//
//
//  Created by Mikhail Maslo on 02.10.23.
//

#if canImport(Foundation)
    import Foundation

    /// Decodes and encodes `yyyy-MM-dd` date in ``ValueStrategy(_:)``
    ///
    /// Example: `2023-10-03`
    public typealias YearMonthDayDate = DateFormatterStrategy<YearMonthDayDateFormatterProvider>

    /// Provides `yyyy-MM-dd` date formatter
    ///
    /// Example: `2023-10-03`
    public struct YearMonthDayDateFormatterProvider: DateFormatterProvider {
        public static let dateFormatter: DateFormatterProtocol = {
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter
        }()
    }
#endif
