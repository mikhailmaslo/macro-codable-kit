//
//  OptionalProtocol.swift
//
//
//  Created by Mikhail Maslo on 03.10.23.
//

/// A protocol that represents an optional value.
///
/// This protocol is useful to handle optional types in decoding and encoding
public protocol OptionalProtocol {
    associatedtype Wrapped

    /// Converts the value to an optional.
    ///
    /// - Returns: The wrapped value if it exists, otherwise `nil`.
    func asOptional() -> Wrapped?
}

extension Optional: OptionalProtocol {
    public func asOptional() -> Wrapped? {
        switch self {
        case let .some(wrapped):
            return wrapped
        case .none:
            return nil
        }
    }
}
