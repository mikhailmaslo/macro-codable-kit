//
//  OneOfMacroBase.Diagnostic.swift
//
//
//  Created by Mikhail Maslo on 21.09.23.
//

import MacroToolkit
import SwiftDiagnostics

extension OneOfMacroBase {
    enum Diagnostic {
        static var requiresEnum: SimpleDiagnosticMessage {
            .error(
                message: "'@\(MacroConfiguration.current.name)' macro can only be applied to a enum",
                diagnosticID: MessageID(domain: MacroConfiguration.current.name, id: #function)
            )
        }

        static var requiresAssociatedValue: SimpleDiagnosticMessage {
            .error(
                message: "'@\(MacroConfiguration.current.name)' macro requires each case to have one associated value",
                diagnosticID: MessageID(domain: MacroConfiguration.current.name, id: #function)
            )
        }
    }
}
