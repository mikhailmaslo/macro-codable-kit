//
//  Type+Helpers.swift
//
//
//  Created by Mikhail Maslo on 07.10.23.
//

import MacroToolkit

extension MacroToolkit.`Type` {
    func typeDescription(preservingOptional: Bool) -> String {
        var result: String
        switch self {
        case let .optional(optionalType):
            result = preservingOptional ? optionalType._baseSyntax.trimmedDescription : optionalType._baseSyntax.wrappedType.trimmedDescription
        default:
            result = _baseSyntax.trimmedDescription
        }
        return "\(result).self"
    }
}
