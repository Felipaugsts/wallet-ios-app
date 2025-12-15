//
//  SettingsViewModel.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 20/10/25.
//

import SwiftUI

class SettingsViewModel: ObservableObject {
    
    @Published var values: [String: Bool] = [:]
    @Published var pickerValues: [String: Int] = [:]
    @Published var isLoading: Bool = true
    @Published var sections: [SectionModel] = SettingsResponse.mock().sections
    @Published var didLogOut: Bool = false
    
    func setBinding(for id: String) -> Binding<Bool> {
        return Binding<Bool>(
            get: {
                self.values[id] ?? false
            },
            set: { newValue in
                self.values[id] = newValue
                
                print("O toggle '\(id)' foi atualizado para \(newValue)")
                
                if id == "theme" {
                    self.changeTheme(toDarkMode: newValue)
                }
                
                if id == "biometric_auth" {
                    UserRepository.shared.isBiometricEnabled = newValue
                }
            }
        )
    }
    
    func pickerBinding(for title: String) -> Binding<Int> {
        return Binding<Int>(
            get: {
                self.pickerValues[title] ?? 0
            },
            set: { newValue in
                self.pickerValues[title] = newValue
                print("O picker '\(title)' foi atualizado para \(newValue)")
                
                if title == "language" {
                    self.changeLanguage(to: newValue)
                }
            }
        )
    }
    
    func loadDefaultSelectedValues() {
        let language = LocalizationManager.shared.language == .english ? 1 : 0
        pickerValues["language"] = language
        
        let isDarkMode = UserDefaultsUtils.shared.getDarkMode()
        values["theme"] = isDarkMode
        values["biometric_auth"] = UserRepository.shared.isBiometricEnabled
    }
    
    func changeTheme(toDarkMode: Bool) {
        ThemeManager.shared.updateTheme(toDarkMode ? .dark : .light)
    }
    
    func changeLanguage(to index: Int) {
        let newLanguage: SelectedLanguage
        
        if index == 1 {
            newLanguage = .english
        } else {
            newLanguage = .portuguese
        }
        
        LocalizationManager.shared.language = newLanguage
    }
    
    func fetchData() {
        let sectionValues = RemoteConfigManager.shared.model(model: SettingsResponse.self, for: .configurationView)
        sections = sectionValues?.sections ?? []
        loadDefaultSelectedValues()
        isLoading = false
    }
    
    func logout() {
        UserRepository.shared.logout()
    }
}


class Constants {
    public static let DARK_MODE = "DARK_MODE"
    public static let LIGHT_MODE = "LIGHT_MODE"
}

class UserDefaultsUtils {
    static var shared = UserDefaultsUtils()
    func setDarkMode(enable: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(enable, forKey: Constants.DARK_MODE)
    }
    func getDarkMode() -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: Constants.DARK_MODE)
    }
}
