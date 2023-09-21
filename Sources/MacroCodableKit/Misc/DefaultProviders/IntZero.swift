//
//  IntZero.swift
//
//
//  Created by Mikhail Maslo on 01.10.23.
//

/**
 A type alias for `DefaultIntZeroValueProvider`.

 - Note: This typealias is used to provide a default value of zero for `Int` types.

 - SeeAlso: `DefaultIntZeroValueProvider`
 */
public typealias IntZero = DefaultIntZeroValueProvider

/**
 A struct that provides a default value of zero for `Int` types.

 - Note: This struct conforms to the `DefaultValueProvider` protocol.

 - SeeAlso: `DefaultValueProvider`
 */
public struct DefaultIntZeroValueProvider: DefaultValueProvider {
    public static var defaultValue: Int { 0 }
}
