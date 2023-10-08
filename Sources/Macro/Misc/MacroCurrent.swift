//
//  MacroConfiguration.swift
//
//
//  Created by Mikhail Maslo on 07.10.23.
//

import SwiftDiagnostics
import SwiftSyntaxMacros

struct MacroConfiguration {
    fileprivate static var _current: Self!

    static var current: Self {
        guard let _current else {
            preconditionFailure("Use withMacro(_:in:operation)")
        }
        return _current
    }

    /// Convention: Macro types should end with "Macro". If the name of the macro is "StringifyAndSquareMacro",
    /// then user macro name should be "macro StringifyAndSquare(...) = #externalMacro(...)"
    let macro: Macro.Type

    let context: MacroExpansionContext

    /// name is Macro type with dropped "Macro" suffix
    var name: String {
        Self.makeName(macro: macro)
    }

    static func makeName(macro: Macro.Type) -> String {
        String("\(macro)".dropLast("Macro".count))
    }
}

func withMacro<R>(
    _ macro: Macro.Type,
    in context: some MacroExpansionContext,
    operation: () throws -> R
) rethrows -> R {
    MacroConfiguration._current = MacroConfiguration(macro: macro, context: context)

    return try operation()
}
