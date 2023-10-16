//
//  Codable.swift
//
//
//  Created by Mikhail Maslo on 26.09.23.
//

/// Generates `Decodable` and `Encodable` conformances respecting property annotations.
///
/// Conform to default `Decodable` and `Encodable` annotating needed type with `@Codable`
/// ```swift
/// @Codable
/// struct User {
///     let birthday: Date
///     let name: String
///     let isVerified: Bool
/// }
/// ```
///
/// If you need only `Decodable` or `Encodable` use ``Decodable()`` or ``Encodable()`` respectively
///
/// **Adjust coding behaviour**:
/// - Adjust coding key with ``CodingKey(_:)``
/// ```swift
/// @Codable
/// struct User {
///     let birthday: Date
///     let name: String
///     @CodingKey("is_verified")
///     let isVerified: Bool
/// }
/// ```
///
/// - Skip coding entirely by using ``OmitCoding()``
/// ```swift
/// @Codable
/// struct User {
///     let birthday: Date
///     let name: String
///     @OmitCoding
///     let isVerified: Bool
/// }
/// ```
///
/// - Provide default value if coding fails or there's no such key with ``DefaultValue(_:)``
/// ```swift
/// @Codable
/// struct User {
///     let birthday: Date
///     let name: String
///     @DefaultValue(BoolFalse)
///     let isVerified: Bool
/// }
/// ```
///
/// - Use custom decoding and encoding strategy with ``ValueStrategy(_:)``. For example, for Date conversion:
/// ```swift
/// @Codable
/// struct User {
///     @ValueStrategy(TimestampedDate)
///     let birthday: Date
///     let name: String
///     let isVerified: Bool
/// }
/// ```
/// corresponding json
/// ```
/// {
///     "birthday":"1696291200.0",
///     "isVerified":true,
///     "name":"Mikhail"
/// }
/// ```
///
/// - Customize encoding and decoding strategies for complex or non-standard data handling with ``CustomCoding(_:)``:
///
/// ```swift
/// @Codable
/// struct User {
///     let birthday: Date
///     let name: String
///     let isVerified: Bool
///     // Decoding won't fail if some elements are invalid
///     @CustomCoding(SafeDecoding)
///     let followers: [User]
///     // Decoding won't fail if some dictionary values are invalid
///     @CustomCoding(SafeDecoding)
///     let followerById: [String: User]
/// }
/// ```
/// **Error Handling**:
/// - Handle decoding errors with ``CustomCodingDecoding/errorHandler`` in ``CustomCodingDecoding``
/// - Handle encoding errors with ``CustomCodingEncoding/errorHandler`` in ``CustomCodingEncoding``
@attached(extension, conformances: Decodable, Encodable, names: named(CodingKeys), named(init(from:)), named(encode(to:)))
public macro Codable() = #externalMacro(module: "Macro", type: "CodableMacro")

/// Generates `Decodable` conformance respecting property annotations.
///
/// The usage and behavior of annotations are analogous to the ``Codable()`` macro but exclusively geared towards decoding.
///
/// Conform to default `Decodable` annotating needed type with `@Decodable`
/// ```swift
/// @Decodable
/// struct Example {
///     let property: String
/// }
/// ```
@attached(extension, conformances: Decodable, names: named(CodingKeys), named(init(from:)))
public macro Decodable() = #externalMacro(module: "Macro", type: "DecodableMacro")

/// Generates `Encodable` conformance respecting property annotations.
///
/// The usage and behavior of annotations are analogous to the ``Codable()`` macro but exclusively geared towards encoding.
///
/// Conform to default `Encodable` annotating needed type with `@Encodable`
/// ```swift
/// @Decodable
/// struct Example {
///     let property: String
/// }
/// ```
@attached(extension, conformances: Encodable, names: named(CodingKeys), named(encode(to:)))
public macro Encodable() = #externalMacro(module: "Macro", type: "EncodableMacro")
