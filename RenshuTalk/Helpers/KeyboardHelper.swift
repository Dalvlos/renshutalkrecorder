//
//  KeyboardHelper.swift
//  RenshuTalk
//
//  Created by Dalvlos on 2025/10/21.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

extension View {
    /// Esconde o teclado (funciona em iOS). Uso: someView.hideKeyboard()
    func hideKeyboard() {
        #if canImport(UIKit)
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
        #endif
    }
}
