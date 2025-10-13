//
//  LanguageManager.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 11/10/25.
//

import SwiftUI
import Combine

class LanguageManager: ObservableObject {
    @Published var currentLanguage: Language = .english
    
    enum Language {
        case portuguese
        case english
    }
    
    var localizedString: String {
        switch currentLanguage {
        case .portuguese:
            return NSLocalizedString("greeting", comment: "")
        case .english:
            return NSLocalizedString("greeting", comment: "")
        }
    }
    
    func toggleLanguage() {
        currentLanguage = currentLanguage == .portuguese ? .english : .portuguese
    }
}
