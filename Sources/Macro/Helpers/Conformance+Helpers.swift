//
//  Conformance+Helpers.swift
//
//
//  Created by Mikhail Maslo on 23.09.23.
//

import SwiftSyntax

extension Conformance {
    static func makeConformances(declaration: some DeclGroupSyntax) -> Set<Conformance> {
        let inheritedTypeDescriptions = declaration.inheritanceClause?.inheritedTypes
            .map { inheritedType in
                inheritedType.type.trimmedDescription
            } ?? []
        return Conformance.makeConformances(inheritedTypeDescriptions)
    }
}
