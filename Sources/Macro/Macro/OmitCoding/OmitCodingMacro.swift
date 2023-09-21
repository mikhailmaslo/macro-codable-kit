//
//  OmitCodingMacro.swift
//
//
//  Created by Mikhail Maslo on 24.09.23.
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct OmitCodingMacro {}

extension OmitCodingMacro: PeerMacro {
    public static func expansion(
        of _: AttributeSyntax,
        providingPeersOf _: some DeclSyntaxProtocol,
        in _: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        []
    }
}
