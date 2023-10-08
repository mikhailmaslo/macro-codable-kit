//
//  CodingKey.swift
//
//
//  Created by Mikhail Maslo on 24.09.23.
//

import MacroToolkit
import SwiftSyntax

struct CodingKey {
    let key: String

    init?(_ attribute: Attribute) {
        guard attribute.name._baseSyntax.name.trimmedDescription == "\(CodingKey.self)" else {
            return nil
        }
        guard let key = attribute.asMacroAttribute?.arguments.first?.1.asStringLiteral?.value else {
            return nil
        }

        self.key = key
    }
}
