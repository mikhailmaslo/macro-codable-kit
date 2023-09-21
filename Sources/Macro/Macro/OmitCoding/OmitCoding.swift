//
//  OmitCoding.swift
//
//
//  Created by Mikhail Maslo on 24.09.23.
//

import MacroToolkit
import SwiftSyntax

struct OmitCoding {
    let attribute: Attribute

    init?(_ attribute: Attribute) {
        guard attribute.name._baseSyntax.name.trimmedDescription == "\(Self.self)" else {
            return nil
        }

        self.attribute = attribute
    }
}
