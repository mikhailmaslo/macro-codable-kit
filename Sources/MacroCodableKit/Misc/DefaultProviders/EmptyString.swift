//
//  EmptyString.swift
//
//
//  Created by Mikhail Maslo on 01.10.23.
//

/**
 A typealias for the default empty string value provider.

 - Note: This typealias is used to provide a default empty string value.

 - SeeAlso: `DefaultEmptyStringValueProvider`
 */
public typealias EmptyString = DefaultEmptyStringValueProvider

/**
 A struct that provides the default empty string value.

 - Note: This struct is used to provide a default empty string value.

 - SeeAlso: `EmptyString`
 */
public struct DefaultEmptyStringValueProvider: DefaultValueProvider {
    public static var defaultValue: String { "" }
}
