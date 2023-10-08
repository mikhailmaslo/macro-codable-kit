//
//  CommonDiagnostic.swift
//
//
//  Created by Mikhail Maslo on 07.10.23.
//

import MacroToolkit
import SwiftDiagnostics

enum CommonDiagnostic {
    static func requiresStruct() -> SimpleDiagnosticMessage {
        .error(
            message: "'@\(MacroConfiguration.current.name)' macro can only be applied to a struct",
            diagnosticID: MessageID(id: #function)
        )
    }

    static func redundantAttributeError(annotation: String, variable _: String) -> SimpleDiagnosticMessage {
        .error(
            message: "'@\(annotation)' attribute has been applied more than once. Redundant attribute applications have no effect on the generated code and may cause confusion.",
            diagnosticID: MessageID(id: #function)
        )
    }

    static func unsupportedCompoundDeclarationError() -> SimpleDiagnosticMessage {
        .error(
            message: "'@\(MacroConfiguration.current.name)' macro is not applicable to compound declarations, declare each variable on a new line",
            diagnosticID: MessageID(id: #function)
        )
    }

    static func missingTypeOfIdentifierError() -> SimpleDiagnosticMessage {
        .error(
            message: "'@\(MacroConfiguration.current.name)' macro is only applicable to declarations with an identifier followed by a type",
            diagnosticID: MessageID(id: #function)
        )
    }

    static func applicableOnlyToStoredProperties() -> SimpleDiagnosticMessage {
        .error(
            message: "'@\(MacroConfiguration.current.name)' macro is only applicable to stored properties declared with an identifier followed by a type, example: `let variable: Int`",
            diagnosticID: MessageID(id: #function)
        )
    }

    static func internalError(
        function: StaticString = #function,
        line: Int = #line,
        file: StaticString = #file,
        message: String
    ) -> SimpleDiagnosticMessage {
        .errorWithContext(
            function: function,
            line: line,
            file: file,
            message: message,
            diagnosticID: MessageID(domain: MacroConfiguration.current.name, id: #function)
        )
    }
}

enum CommonError: Error {
    case diagnosticError
}
