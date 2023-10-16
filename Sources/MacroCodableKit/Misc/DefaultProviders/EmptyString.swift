//
//  EmptyString.swift
//
//
//  Created by Mikhail Maslo on 01.10.23.
//

/// Provides a default `""` value for strings in ``DefaultValue(_:)``.
public typealias EmptyString = DefaultEmptyStringValueProvider

/// A struct that provides a default value of `""` for string.
public struct DefaultEmptyStringValueProvider: DefaultValueProvider {
    public static var defaultValue: String { "" }
}
