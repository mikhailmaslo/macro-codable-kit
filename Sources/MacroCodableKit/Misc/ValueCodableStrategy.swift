//
//  ValueCodableStrategy.swift
//
//
//  Created by Mikhail Maslo on 30.09.23.
//

/// A strategy for encoding and decoding a property of type ``Value``.
///
/// The ``Value`` is the same as it appears in the property it's applied to, for example:
///
/// ```swift
/// @Codable
/// struct Example {
///     @ValueStrategy(SomeConcreteValueStrategy)
///     var property: ConcreteValue
/// }
/// ```
///
/// In this snippet above, **SomeConcreteValueStrategy** will have **ConcreteValue** type and could be applied only to properties of this type.
public protocol ValueCodableStrategy<Value> {
    /// The type of value that this strategy encodes and decodes.
    associatedtype Value

    /// Decodes a value of the associated type from the given decoder.
    ///
    /// - Parameter decoder: The decoder to read data from.
    ///
    /// - Throws: An error if decoding fails.
    ///
    /// - Returns: The decoded value from decoder.
    static func decode(from decoder: Decoder) throws -> Value

    /// Encodes the given value using the associated type.
    ///
    /// - Parameter value: The value to encode.
    /// - Parameter encoder: The encoder to write data to.
    ///
    /// - Throws: An error if the value cannot be encoded.
    static func encode(value: Value, to encoder: Encoder) throws
}
