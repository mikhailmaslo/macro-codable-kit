//
//  File.swift
//
//
//  Created by Mikhail Maslo on 07.10.23.
//

import SwiftDiagnostics

extension MessageID {
    init(id: String) {
        self.init(
            domain: MacroConfiguration.current.name,
            id: id
        )
    }
}
