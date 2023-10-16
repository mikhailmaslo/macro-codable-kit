//
//  DefaultValueStrategy.swift
//
//
//  Created by Mikhail Maslo on 26.09.23.
//

/// A protocol for providing default values in ``DefaultValue(_:)`` macro
public protocol DefaultValueProvider {
    /// The type of the default value.
    associatedtype DefaultValue: Codable

    /// The default value.
    static var defaultValue: DefaultValue { get }
}
