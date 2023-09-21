//
//  BoolFalse.swift
//
//
//  Created by Mikhail Maslo on 26.09.23.
//

/**
 A typealias for `DefaultFalseValueProvider`.

 This typealias is used to provide a default value of `false` for `Bool` types.

 - Note: This typealias conforms to `DefaultValueProvider`.
 */
public typealias BoolFalse = DefaultFalseValueProvider

/**
 A struct that provides a default value of `false` for `Bool` types.

 This struct conforms to `DefaultValueProvider`.
 */
public struct DefaultFalseValueProvider: DefaultValueProvider {
    /// The default value of `false`.
    public static var defaultValue: Bool { false }
}
