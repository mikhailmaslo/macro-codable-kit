//
//  Instance.swift
//
//
//  Created by Mikhail Maslo on 25.09.23.
//

import MacroToolkit
import SwiftSyntax

protocol Instance {
    var declaration: any DeclGroupSyntax { get }

    var members: [Decl] { get }
}

extension Instance {
    var isPublic: Bool { declaration.isPublic }
}

final class InstanceImpl: Instance {
    let declaration: any DeclGroupSyntax
    let isStruct: Bool
    let members: [Decl]

    init?(declaration: any DeclGroupSyntax) {
        if let `struct` = Struct(declaration) {
            members = `struct`.members
            isStruct = true
        } else if let `class` = ClassDecl(declaration) {
            members = `class`.members
            isStruct = false
        } else {
            return nil
        }
        self.declaration = declaration
    }
}
