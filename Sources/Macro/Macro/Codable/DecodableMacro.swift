//
//  DecodableMacro.swift
//
//
//  Created by Mikhail Maslo on 26.09.23.
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct DecodableMacro {}

extension DecodableMacro: ExtensionMacro {
    private static let expectedConformances: Set<Conformance> = [.Decodable]

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        try withMacro(Self.self, in: context) {
            let conformancesToGenerate = Conformance.makeConformances(protocols: protocols, declaration: declaration, type: type, expectedConformances: expectedConformances)
            return try CodableMacroBase.expansion(
                of: node,
                attachedTo: declaration,
                providingExtensionsOf: type,
                conformancesToGenerate: conformancesToGenerate,
                expectedConformances: expectedConformances,
                in: context
            )
        }
    }
}
