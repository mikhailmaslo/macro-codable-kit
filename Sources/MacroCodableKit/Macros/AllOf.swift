//
//  AllOf.swift
//
//
//  Created by Mikhail Maslo on 26.09.23.
//

/// Generates `Decodable` and `Encodable` conformances following the OpenAPI `allOf` specification for composition.
///
/// Use a struct to describe openAPI `allOf` relationship:
/// ```swift
/// @AllOfCodable
/// private struct AllOfExample: Equatable {
///     struct B: Codable, Equatable {
///         let int: Int
///         let boolean: Bool
///         let string: String
///     }
///     struct C: Codable, Equatable {
///         let anotherInt: Int
///     }
///
///     let b: B
///     let c: C
/// }
/// ```
///
/// Corresponding json:
/// ```
/// {
///     "int": 1,
///     "boolean": true,
///     "string": "some string",
///     "anotherInt": 1
/// }
/// ```
@attached(extension, conformances: Decodable, Encodable, names: named(CodingKeys), named(init(from:)), named(encode(to:)))
public macro AllOfCodable() = #externalMacro(module: "Macro", type: "AllOfCodableMacro")

/// Generates `Decodable` conformance following the OpenAPI `allOf` specification for composition.
///
/// Use a struct to describe openAPI `allOf` relationship:
/// ```swift
/// @AllOfDecodable
/// private struct AllOfExample: Equatable {
///     struct B: Codable, Equatable {
///         let int: Int
///         let boolean: Bool
///         let string: String
///     }
///     struct C: Codable, Equatable {
///         let anotherInt: Int
///     }
///
///     let b: B
///     let c: C
/// }
/// ```
///
/// Corresponding json:
/// ```
/// {
///     "int": 1,
///     "boolean": true,
///     "string": "some string",
///     "anotherInt": 1
/// }
/// ```
@attached(extension, conformances: Decodable, names: named(CodingKeys), named(init(from:)))
public macro AllOfDecodable() = #externalMacro(module: "Macro", type: "AllOfDecodableMacro")

/// Generates `Encodable` conformance following the OpenAPI `allOf` specification for composition.
///
/// Use a struct to describe openAPI `allOf` relationship:
/// ```swift
/// @AllOfEncodable
/// private struct AllOfExample: Equatable {
///     struct B: Codable, Equatable {
///         let int: Int
///         let boolean: Bool
///         let string: String
///     }
///     struct C: Codable, Equatable {
///         let anotherInt: Int
///     }
///
///     let b: B
///     let c: C
/// }
/// ```
///
/// Corresponding json:
/// ```
/// {
///     "int": 1,
///     "boolean": true,
///     "string": "some string",
///     "anotherInt": 1
/// }
/// ```
@attached(extension, conformances: Encodable, names: named(CodingKeys), named(encode(to:)))
public macro AllOfEncodable() = #externalMacro(module: "Macro", type: "AllOfEncodableMacro")
