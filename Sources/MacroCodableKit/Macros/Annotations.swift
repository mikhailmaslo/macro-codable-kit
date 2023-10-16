//
//  Annotations.swift
//
//
//  Created by Mikhail Maslo on 26.09.23.
//

/// Changes default codingKey of a property to the specified `key`.
///
/// Adjust coding key annotating
/// ```swift
/// @Codable
/// struct User {
///     let birthday: Date
///     let name: String
///     @CodingKey("is_verified")
///     let isVerified: Bool
/// }
/// ```
@attached(peer)
public macro CodingKey(_ key: String) = #externalMacro(module: "Macro", type: "CodingKeyMacro")

/// Ignores a property in encoding and decoding
///
/// Skip coding entirely
/// ```swift
/// @Codable
/// struct User {
///     let birthday: Date
///     let name: String
///     @OmitCoding
///     let isVerified: Bool
/// }
/// ```
@attached(peer)
public macro OmitCoding() = #externalMacro(module: "Macro", type: "OmitCodingMacro")

/// Provides default value if coding fails or there's no such key
///
/// Each provider should be of the same type as a property it attached to
/// ```swift
/// @Codable
/// struct User {
///     let birthday: Date
///     @DefaultValue(EmptyString)
///     let name: String
///     @DefaultValue(BoolFalse)
///     let isVerified: Bool
/// }
/// ```
///
/// - If a value is decoded with an error, the default is returned by the given ``DefaultValueProvider``.
/// - Doesn't have effect on encoding.
/// - During decoding, any non-thrown errors encountered is sent to ``CustomCodingDecoding/errorHandler``
@attached(peer)
public macro DefaultValue<Provider: DefaultValueProvider>(
    _ type: Provider.Type
) = #externalMacro(module: "Macro", type: "DefaultValueMacro")

/// Customizes decoding and encoding of a specific type
///
/// If your type is generic or it can't be described a static one, for example, `Array<Element>` with an unknown generic `Element` type, then you should use ``CustomCoding(_:)``
///
/// Annotate needed property and provided a strategy. In this example, we use build-in ``TimestampedDate``, which converts timestamp to `Date`
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
/// - The custom strategy is defined by implementing the `ValueCodableStrategy` protocol.
/// - Can be used in conjunction with the `DefaultValue` annotation. If decoding with the provided strategy fails, the default value is used.
/// - During decoding and encoding, any non-thrown errors encountered is sent to ``CustomCodingDecoding/errorHandler`` or ``CustomCodingEncoding/errorHandler`` respectively.
@attached(peer)
public macro ValueStrategy<Strategy: ValueCodableStrategy>(
    _ strategy: Strategy.Type
) = #externalMacro(module: "Macro", type: "ValueStrategyMacro")

/// Customizes decoding and encoding of any type following conventions
/// 
/// This macro modifies the generated `Codable` conformance, redirecting the encoding and decoding of the annotated property to custom functions.
///
/// The name of the custom functions is derived from the type name passed to the ``CustomCoding(_:)`` annotation. For instance, `@CustomCoding(SafeDecoding)` directs the ``Codable()`` macro to use the `SafeDecoding` function in ``CustomCodingDecoding/safeDecoding(_:forKey:container:)-1qnwn`` and ``CustomCodingEncoding/safeDecoding(_:forKey:container:)-7cwmw`` for decoding and encoding respectively.
///
/// Annotate needed property and provided a strategy. In this example, we use build-in ``SafeDecoding``, which ignores elements decoded with an error
/// ```swift
/// @Codable
/// struct ArrayExample: Equatable {
///     @CustomCoding(SafeDecoding)
///     var elements: [Element]
/// }
/// ```
///
/// **Build-in**:
/// - `SafeDecoding`: A custom decoding strategy that safely handles decoding errors for arrays and dictionaries.
///
/// **Note**:
/// - Implementations in ``CustomCodingDecoding`` and ``CustomCodingEncoding`` are required.
@attached(peer)
public macro CustomCoding<Name: CustomDecodingName>(
    _ name: Name.Type
) = #externalMacro(module: "Macro", type: "CustomCodingMacro")
