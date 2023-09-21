//
//  ClassDecl.swift
//
//
//  Created by Mikhail Maslo on 25.09.23.
//

import MacroToolkit
import SwiftSyntax

struct ClassDecl {
    /// The underlying syntax node.
    public var _syntax: ClassDeclSyntax

    /// Wraps a syntax node.
    public init(_ syntax: ClassDeclSyntax) {
        _syntax = syntax
    }

    /// Attempts to get a declaration group as a struct declaration.
    public init?(_ syntax: any DeclGroupSyntax) {
        guard let syntax = syntax.as(ClassDeclSyntax.self) else {
            return nil
        }
        _syntax = syntax
    }

    /// The struct's members.
    public var members: [Decl] {
        _syntax.memberBlock.members.map(\.decl).map(Decl.init)
    }

    /// Types that the struct conforms to.
    public var inheritedTypes: [Type] {
        _syntax.inheritanceClause?.inheritedTypes.map(\.type).map(Type.init) ?? []
    }

    /// Whether the `struct` was declared with the `public` access level modifier.
    public var isPublic: Bool {
        _syntax.isPublic
    }
}
