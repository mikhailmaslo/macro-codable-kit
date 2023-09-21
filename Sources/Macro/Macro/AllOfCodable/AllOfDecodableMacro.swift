//
//  AllOfDecodableMacro.swift
//
//
//  Created by Mikhail Maslo on 25.09.23.
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct AllOfDecodableMacro: MacroMetaProviding {
    static let name: String = "AllOfDecodable"
    static let domain: String = "\(Self.self)"
}

extension AllOfDecodableMacro: ExtensionMacro {
    private static let expectedConformances: Set<Conformance> = [.Decodable]

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo _: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let existingConformances = Conformance.makeConformances(declaration: declaration)
        let neededConformances = expectedConformances.subtracting(existingConformances)
        return try AllOfMacroBase.expansion(
            of: node,
            attachedTo: declaration,
            providingExtensionsOf: type,
            conformingTo: neededConformances.map { TypeSyntax(stringLiteral: $0.rawValue) },
            in: context,
            macro: Self.self
        )
    }
}
