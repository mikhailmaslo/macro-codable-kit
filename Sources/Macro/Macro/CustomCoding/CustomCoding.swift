//
//  CustomCoding.swift
//
//
//  Created by Mikhail Maslo on 01.10.23.
//

import MacroToolkit
import SwiftSyntax

struct CustomCoding {
    let codingNameType: String

    init?(_ attribute: Attribute) {
        guard attribute.name._baseSyntax.name.trimmedDescription == "\(Self.self)" else {
            return nil
        }
        guard let codingNameType = attribute.asMacroAttribute?.arguments.first?.1._syntax._syntaxNode.trimmedDescription else {
            return nil
        }

        self.codingNameType = codingNameType
    }
}
