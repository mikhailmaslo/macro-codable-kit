//
//  CodableMacroBase.Diagnostic.swift
//
//
//  Created by Mikhail Maslo on 23.09.23.
//

import MacroToolkit
import SwiftDiagnostics

extension CodableMacroBase {
    enum Diagnostic {
        static var requiresStructOrClass: SimpleDiagnosticMessage {
            .error(
                message: "'\(CodableMacroBase.name)' macro can only be applied to a struct or to a class",
                diagnosticID: MessageID(domain: CodableMacroBase.domain, id: #function)
            )
        }

        static func internalError(message: String) -> SimpleDiagnosticMessage {
            .errorWithContext(
                message: message,
                diagnosticID: MessageID(domain: CodableMacroBase.domain, id: #function)
            )
        }
    }
}
