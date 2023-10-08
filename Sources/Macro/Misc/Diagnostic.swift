//
//  Diagnostic.swift
//
//
//  Created by Mikhail Maslo on 21.09.23.
//

import MacroToolkit
import SwiftDiagnostics

extension SimpleDiagnosticMessage {
    static func error(message: String, diagnosticID: MessageID) -> SimpleDiagnosticMessage {
        SimpleDiagnosticMessage(message: message, diagnosticID: diagnosticID, severity: .error)
    }

    static func errorWithContext(
        function: StaticString = #function,
        line: Int = #line,
        file: StaticString = #file,
        message: String,
        diagnosticID: MessageID
    ) -> SimpleDiagnosticMessage {
        .error(message: "\(file):\(line) \(function) \(message)", diagnosticID: diagnosticID)
    }

    static func warning(message: String, diagnosticID: MessageID) -> SimpleDiagnosticMessage {
        SimpleDiagnosticMessage(message: message, diagnosticID: diagnosticID, severity: .warning)
    }

    // periphery:ignore
    static func note(message: String, diagnosticID: MessageID) -> SimpleDiagnosticMessage {
        SimpleDiagnosticMessage(message: message, diagnosticID: diagnosticID, severity: .note)
    }
}
