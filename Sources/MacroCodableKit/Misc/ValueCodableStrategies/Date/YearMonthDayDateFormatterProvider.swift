//
//  YearMonthDayDateFormatterProvider.swift
//
//
//  Created by Mikhail Maslo on 02.10.23.
//

#if canImport(Foundation)
    import Foundation

    /// A typealias for `DateFormatterStrategy` using `YearMonthDayDateFormatterProvider`.
    public typealias YearMonthDayDate = DateFormatterStrategy<YearMonthDayDateFormatterProvider>

    /**
     A provider for `DateFormatter` with the format "yyyy-MM-dd".

     This provider is specifically designed for formatting dates in the "yyyy-MM-dd" format.

     - SeeAlso: `DateFormatterStrategy`, `DateFormatterProvider`
     */
    public struct YearMonthDayDateFormatterProvider: DateFormatterProvider {
        /// The shared `DateFormatter` instance.
        public static let dateFormatter: DateFormatterProtocol = {
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter
        }()
    }
#endif
