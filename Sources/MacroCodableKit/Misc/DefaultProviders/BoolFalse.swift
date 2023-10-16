//
//  BoolFalse.swift
//
//
//  Created by Mikhail Maslo on 26.09.23.
//

/// Provides a default `false` value for booleans in ``DefaultValue(_:)``.
public typealias BoolFalse = DefaultFalseValueProvider

/// A struct that provides a default value of `false` for booleans.
public struct DefaultFalseValueProvider: DefaultValueProvider {
    /// The default value of `false`.
    public static var defaultValue: Bool { false }
}
