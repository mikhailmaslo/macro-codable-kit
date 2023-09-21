//
//  AllOfMacroBase.Diagnostic.swift
//
//
//  Created by Mikhail Maslo on 23.09.23.
//

import MacroToolkit
import SwiftDiagnostics

extension AllOfMacroBase {
    enum Diagnostic {
        static var requiresStructOrClass: SimpleDiagnosticMessage {
            .error(
                message: "'\(AllOfMacroBase.name)' macro can only be applied to a struct or to a class",
                diagnosticID: MessageID(domain: AllOfMacroBase.domain, id: #function)
            )
        }

        static var requiresEitherEncodableOrDecodable: SimpleDiagnosticMessage {
            .error(
                message: "'\(AllOfMacroBase.name)' macro can only be applied to a enum conforming to either Encodable or Decodable",
                diagnosticID: MessageID(domain: AllOfMacroBase.domain, id: #function)
            )
        }

        static func internalError(message: String) -> SimpleDiagnosticMessage {
            .errorWithContext(
                message: message,
                diagnosticID: MessageID(domain: AllOfMacroBase.domain, id: #function)
            )
        }
    }
}
