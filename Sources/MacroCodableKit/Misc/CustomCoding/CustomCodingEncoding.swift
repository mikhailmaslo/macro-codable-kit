//
//  CustomCodingEncoding.swift
//
//
//  Created by Mikhail Maslo on 03.10.23.
//

/// Namespace to handle custom encoding strategies.
///
/// Serves as a centralized extension for handling custom encoding strategies across various types. Encoding errros that was ignored  are passed to ``errorHandler``.
///
///
/// For example the following code:
/// ```swift
///  @Encodable
///  struct Exmaple {
///     @ValueStrategy(SomeVariableStrategy)
///     let variable: SomeVariable
///  }
/// ```
///
/// Will generate `Encodable` conformance using ``CustomCodingEncoding`` for variables with custom coding
/// ```swift
/// extension Exmaple: Encodable {
///     enum CodingKeys: String, CodingKey {
///         case variable
///     }
///     func encode(to encoder: Encoder) throws {
///         var container = encoder.container(keyedBy: CodingKeys.self)
///         try CustomCodingEncoding.encode(
///             self.variable,
///             forKey: .variable,
///             container: &container,
///             strategy: SomeVariableStrategy.self
///         )
///     }
/// }
/// ```
///
/// Custom strategies utilize this namespace to implement encoding implementations which then is used by ``Codable()`` and  ``Encodable()``.
///
/// You can provide encoding logic yourself by using ``CustomCoding(_:)`` and implementing needed extension in ``CustomCodingEncoding``. See build-in ``SafeDecoding`` along with ``safeDecoding(_:forKey:container:)-7cwmw`` and ``safeDecoding(_:forKey:container:)-9b19z``.
public enum CustomCodingEncoding {
    /// A closure that handles errors during coding and encoding operations.
    ///
    /// A closure that captures and handles any errors encountered during the encoding process. The handling might include logging the error for debugging purposes or taking other actions as needed.
    public static var errorHandler: ((Error) -> Void)?

    /// Logs an unhandled error during an encoding operation through ``errorHandler``
    public static func logError(_ error: Error) {
        errorHandler?(error)
    }
}
