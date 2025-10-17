//
//  LanguageManager.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 11/10/25.
//

import SwiftUI

@Observable
class LocalizationManager: ObservableObject {
    // MARK: - Variables
    static let shared = LocalizationManager()
    
    var language: SelectedLanguage
    

    init() {
        language = .english
    }

    // MARK: - Methods
    func saveLanguage(_ language: SelectedLanguage) {
        self.language = language
    }
}

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

extension String {
    var localized: String {
        let currentLanguage = LocalizationManager.shared.language.rawValue
        let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj") ?? ""
        let bundle = Bundle(path: path) ?? .main
        return NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")
    }
}
