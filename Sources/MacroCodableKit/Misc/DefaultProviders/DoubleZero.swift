//
//  DoubleZero.swift
//
//
//  Created by Mikhail Maslo on 01.10.23.
//

/**
 A type alias for the default double zero value provider.

 - Note: This typealias provides a more convenient way to access the default double zero value provider.

 - SeeAlso: `DefaultDoubleZeroValueProvider`
 */
public typealias DoubleZero = DefaultDoubleZeroValueProvider

/**
 A struct that provides the default value for double zero.

 - Note: This struct conforms to the `DefaultValueProvider` protocol.

 - SeeAlso: `DefaultValueProvider`
 */
public struct DefaultDoubleZeroValueProvider: DefaultValueProvider {
    /// The default value for double zero.
    public static var defaultValue: Double { 0 }
}
