//
//  CodableKitUtils.swift
//
//
//  Created by Mikhail Maslo on 01.10.23.
//

/// Namespace to handle custom decoding strategies.
///
/// Serves as a centralized extension for handling custom decoding strategies across various types. Decoding errros that was ignored  are passed to ``errorHandler``.
///
///
/// - Example:
/// ```swift
///  @Decodable
///  struct Exmaple {
///     @ValueStrategy(SomeVariableStrategy)
///     let variable: SomeVariable
///  }
/// ```
///
/// Will generate `Decodable` conformance using ``CustomCodingDecoding`` for variables with custom coding
/// ```swift
/// extension Exmaple: Decodable {
///     enum CodingKeys: String, CodingKey {
///         case variable
///     }
///     init(from decoder: Decoder) throws {
///         let container = try decoder.container(keyedBy: CodingKeys.self)
///         self.variable = try CustomCodingDecoding.decode(
///             SomeVariable.self,
///             forKey: .variable,
///             container: container,
///             strategy: SomeVariableStrategy.self
///         )
///     }
/// }
/// ```
///
/// Custom strategies utilize this namespace to implement decoding implementations which then is used by ``Codable()`` and ``Decodable()``.
///
/// You can provide decoding logic yourself by using ``CustomCoding(_:)`` and implementing needed extension in ``CustomCodingDecoding``. See build-in ``SafeDecoding`` along with ``safeDecoding(_:forKey:container:)-1qnwn`` and ``safeDecoding(_:forKey:container:)-3ytig``.
public enum CustomCodingDecoding {
    /// A closure that handles errors during coding and decoding operations.
    ///
    /// A closure that captures and handles any errors encountered during the decoding process. The handling might include logging the error for debugging purposes or taking other actions as needed.
    public static var errorHandler: ((Error) -> Void)?

    /// Logs an unhandled error during an decoding operation through ``errorHandler``
    public static func logError(_ error: Error) {
        errorHandler?(error)
    }
}
