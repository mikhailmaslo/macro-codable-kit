//
//  ValueCodableStrategy.swift
//
//
//  Created by Mikhail Maslo on 30.09.23.
//

/**
 A strategy for encoding and decoding a specific value type.

 - Note: The value type must conform to `Codable`.

 - SeeAlso: `ValueStrategy`
 */
public protocol ValueCodableStrategy {
    /// The type of value that this strategy encodes and decodes.
    associatedtype Value: Codable

    /**
     Decodes a value of the associated type from the given decoder.

     - Parameter decoder: The decoder to read data from.

     - Throws: An error if the value cannot be decoded.

     - Returns: The decoded value.
     */
    static func decode(from decoder: Decoder) throws -> Value

    /**
     Encodes the given value using the associated type.

     - Parameter value: The value to encode.
     - Parameter encoder: The encoder to write data to.

     - Throws: An error if the value cannot be encoded.
     */
    static func encode(value: Value, to encoder: Encoder) throws
}
