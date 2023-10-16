//
//  BoolTrue.swift
//
//
//  Created by Mikhail Maslo on 26.09.23.
//

/// Provides a default `true` value for booleans in ``DefaultValue(_:)``.
public typealias BoolTrue = DefaultTrueValueProvider

/// A struct that provides a default value of `true` for booleans.
public struct DefaultTrueValueProvider: DefaultValueProvider {
    /// The default value of `true`.
    public static var defaultValue: Bool { true }
}
