//
//  DeclModifierListSyntax+Helpers.swift
//
//
//  Created by Mikhail Maslo on 21.09.23.
//

import SwiftSyntax

extension DeclModifierListSyntax {
    func explicitAccessModifier() -> AccessModifier? {
        first(where: { modifier in
            switch modifier.name.tokenKind {
            case .keyword(.public), .keyword(.private), .keyword(.internal):
                return true
            default:
                return false
            }
        }).flatMap {
            AccessModifier(rawValue: $0.trimmedDescription)
        }
    }
}
