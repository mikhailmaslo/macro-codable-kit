//
//  DoubleZero.swift
//
//
//  Created by Mikhail Maslo on 01.10.23.
//

/// Provides a default `0` value for doubles in ``DefaultValue(_:)``.
public typealias DoubleZero = DefaultDoubleZeroValueProvider

/// A struct that provides a default value of `0` for doubles.
public struct DefaultDoubleZeroValueProvider: DefaultValueProvider {
    /// The default value for double zero.
    public static var defaultValue: Double { 0 }
}
