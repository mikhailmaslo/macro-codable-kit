//
//  BoolTrue.swift
//
//
//  Created by Mikhail Maslo on 26.09.23.
//

/**
 A typealias for `DefaultTrueValueProvider`.

 This typealias is used to provide a default value of `true` for booleans.

 - Note: This typealias conforms to `DefaultValueProvider`.
 */
public typealias BoolTrue = DefaultTrueValueProvider

/**
 A struct that provides a default value of `true` for booleans.

 This struct conforms to `DefaultValueProvider`.
 */
public struct DefaultTrueValueProvider: DefaultValueProvider {
    /// The default value of `true`.
    public static var defaultValue: Bool { true }
}
