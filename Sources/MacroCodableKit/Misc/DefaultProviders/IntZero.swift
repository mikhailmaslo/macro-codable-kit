//
//  IntZero.swift
//
//
//  Created by Mikhail Maslo on 01.10.23.
//

/// Provides a default `0` value for ints in ``DefaultValue(_:)``.
public typealias IntZero = DefaultIntZeroValueProvider

/// A struct that provides a default value of `0` for ints.
public struct DefaultIntZeroValueProvider: DefaultValueProvider {
    public static var defaultValue: Int { 0 }
}
