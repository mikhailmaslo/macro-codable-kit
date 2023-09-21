//
//  CodingKeyMacro.swift
//
//
//  Created by Mikhail Maslo on 23.09.23.
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct CodingKeyMacro {}

extension CodingKeyMacro: PeerMacro {
    public static func expansion(
        of _: AttributeSyntax,
        providingPeersOf _: some DeclSyntaxProtocol,
        in _: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        []
    }
}
