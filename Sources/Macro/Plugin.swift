//
//  Plugin.swift
//
//
//  Created by Mikhail Maslo on 21.09.23.
//

#if canImport(SwiftCompilerPlugin)
    import SwiftCompilerPlugin
    import SwiftSyntaxMacros

    @main
    struct Plugin: CompilerPlugin {
        let providingMacros: [Macro.Type] = [
            // One of
            OneOfCodableMacro.self,
            OneOfEncodableMacro.self,
            OneOfDecodableMacro.self,

            // All of
            AllOfCodableMacro.self,
            AllOfDecodableMacro.self,
            AllOfEncodableMacro.self,

            // Codable
            CodableMacro.self,
            EncodableMacro.self,
            DecodableMacro.self,

            // Coding customization
            CodingKeyMacro.self,
            OmitCodingMacro.self,
            DefaultValueMacro.self,
            ValueStrategyMacro.self,
            CustomCodingMacro.self,
        ]
    }
#endif
