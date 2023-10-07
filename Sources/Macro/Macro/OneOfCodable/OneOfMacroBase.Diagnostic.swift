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
                message: "'\(MacroConfiguration.current.name)' macro can only be applied to a enm",
                diagnosticID: MessageID(domain: MacroConfiguration.current.name, id: #function)
            )
        }

        static func internalError(message: String) -> SimpleDiagnosticMessage {
            .errorWithContext(
                message: message,
                diagnosticID: MessageID(domain: MacroConfiguration.current.name, id: #function)
            )
        }
    }
}
