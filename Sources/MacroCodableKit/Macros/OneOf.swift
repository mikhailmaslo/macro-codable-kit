//
//  OneOf.swift
//
//
//  Created by Mikhail Maslo on 26.09.23.
//

/// Generates `Decodable` and `Encodable` conformances following the OpenAPI `oneOf` specification for composition.
///
/// Describe oneOf relationship with enum consisting of cases with a single associated value
/// ```swift
/// @OneOfCodable
/// enum Example {
///     case int(Int)
///     case boolean(Bool)
///     case string(String)
/// }
/// ```
/// Corresponding jsons
/// ```
/// {"int": 100}
/// {"boolean": true}
/// {"string": "Hello world"}
/// ```
@attached(extension, conformances: Decodable, Encodable, names: named(CodingKeys), named(init(from:)), named(encode(to:)))
public macro OneOfCodable() = #externalMacro(module: "Macro", type: "OneOfCodableMacro")

/// Generates `Decodable` conformance following the OpenAPI `oneOf` specification for composition.
///
/// Describe oneOf relationship with enum consisting of cases with a single associated value
/// ```swift
/// @OneOfDecodable
/// enum Example {
///     case int(Int)
///     case boolean(Bool)
///     case string(String)
/// }
/// ```
/// Corresponding jsons
/// ```
/// {"int": 100}
/// {"boolean": true}
/// {"string": "Hello world"}
/// ```
@attached(extension, conformances: Decodable, names: named(CodingKeys), named(init(from:)))
public macro OneOfDecodable() = #externalMacro(module: "Macro", type: "OneOfDecodableMacro")

/// Generates `Encodable` conformance following the OpenAPI `oneOf` specification for composition.
///
/// Describe oneOf relationship with enum consisting of cases with a single associated value
/// ```swift
/// @OneOfEncodable
/// enum Example {
///     case int(Int)
///     case boolean(Bool)
///     case string(String)
/// }
/// ```
/// Corresponding jsons
/// ```
/// {"int": 100}
/// {"boolean": true}
/// {"string": "Hello world"}
/// ```
@attached(extension, conformances: Encodable, names: named(CodingKeys), named(encode(to:)))
public macro OneOfEncodable() = #externalMacro(module: "Macro", type: "OneOfEncodableMacro")
