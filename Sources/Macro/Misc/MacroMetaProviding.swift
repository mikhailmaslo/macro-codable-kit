//
//  MacroMetaProviding.swift
//
//
//  Created by Mikhail Maslo on 25.09.23.
//

import SwiftSyntaxMacros

protocol MacroMetaProviding {
    /// Convention: Macro types should end with "Macro". If the name of the macro is "StringifyAndSquareMacro",
    /// then user macro name should be "macro StringifyAndSquare(...) = #externalMacro(...)"
    static var macro: Macro.Type { get }
}

extension MacroMetaProviding {
    /// Domain is Macro type with dropped "Macro" suffix
    static var domain: String {
        String("\(macro)".dropLast("Macro".count))
    }
}
