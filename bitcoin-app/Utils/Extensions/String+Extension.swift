//
//  String+Extension.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 22/10/25.
//

import Foundation

extension String {
    var localized: String {
        let currentLanguage = LocalizationManager.shared.language.rawValue
        let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj") ?? ""
        let bundle = Bundle(path: path) ?? .main
        return NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")
    }
}
