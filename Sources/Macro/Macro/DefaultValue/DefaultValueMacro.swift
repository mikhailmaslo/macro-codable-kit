//
//  DefaultValue.swift
//
//
//  Created by Mikhail Maslo on 01.10.23.
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct DefaultValueMacro {}

extension DefaultValueMacro: PeerMacro {
    public static func expansion(
        of _: AttributeSyntax,
        providingPeersOf _: some DeclSyntaxProtocol,
        in _: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        []
    }
}
