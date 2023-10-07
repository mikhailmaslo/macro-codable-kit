//
//  MacroConfiguration.swift
//
//
//  Created by Mikhail Maslo on 07.10.23.
//

import SwiftDiagnostics
import SwiftSyntaxMacros

private struct FakeMacro: Macro {}

protocol DiagnosticHandler {
    func handle(_ diagnostic: Diagnostic)
}

struct MacroConfiguration {
    static var current = Self()

    /// Convention: Macro types should end with "Macro". If the name of the macro is "StringifyAndSquareMacro",
    /// then user macro name should be "macro StringifyAndSquare(...) = #externalMacro(...)"
    var macro: Macro.Type = FakeMacro.self

    /// name is Macro type with dropped "Macro" suffix
    var name: String {
        String("\(macro)".dropLast("Macro".count))
    }
}

func withMacro<R>(
    _ macro: Macro.Type,
    operation: () throws -> R
) rethrows -> R {
    MacroConfiguration.current.macro = macro

    return try operation()
}
