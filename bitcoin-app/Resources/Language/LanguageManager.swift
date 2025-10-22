//
//  LanguageManager.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 11/10/25.
//

import SwiftUI

@Observable
class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    var language: SelectedLanguage
    

    init() { language = .english }

    func saveLanguage(_ language: SelectedLanguage) {
        self.language = language
    }
}

// MARK: - Enums

public enum SelectedLanguage: String {
    case english = "en"
    case portuguese = "pt"
    
    var locale: Locale {
        switch self {
        case .english:
            return Locale(identifier: "en")
        case .portuguese:
            return Locale(identifier: "pt")
        }
    }
}
