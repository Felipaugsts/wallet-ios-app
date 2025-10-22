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
    @Published var viewState: ViewState = .loading
    @Published var sections: [SectionModel] = []
    
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
    }
    
    func changeTheme(toDarkMode: Bool) {
        // Verifica se há uma janela disponível e altera o estilo de interface
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.overrideUserInterfaceStyle = toDarkMode ? .dark : .light
        }

        // Atualiza a preferência no UserDefaults
        UserDefaultsUtils.shared.setDarkMode(enable: toDarkMode)
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
        let jsonData = """
{
  "sections": [
    {
      "sectionTitle": "preferences",
      "sectionEnabled": true,
      "sectionOptions": [
        {
          "id": "notification",
          "title": "notification",
          "icon": "bell.fill",
          "color": "orange",
          "enabled": false,
          "type": "toggle"
        },
        {
          "id": "theme",
          "title": "theme",
          "icon": "moon.fill",
          "color": "indigo",
          "enabled": true,
          "type": "toggle"
        },
        {
          "id": "language",
          "title": "language",
          "icon": "dollarsign.circle.fill",
          "color": "green",
          "enabled": true,
          "type": "picker",
          "options": [
            {
              "id": "portuguese",
              "title": "portuguese",
              "tag": 0
            },
            {
              "id": "english",
              "title": "english",
              "tag": 1
            }
          ]
        }
      ]
    },
    {
      "sectionTitle": "security_and_privacy",
      "sectionEnabled": true,
      "sectionOptions": [
        {
          "id": "biometric_auth",
          "title": "biometric_auth",
          "icon": "faceid",
          "color": "blue",
          "enabled": false,
          "type": "toggle"
        },
        {
          "id": "change_password",
          "title": "change_password",
          "icon": "lock.fill",
          "color": "red",
          "enabled": false,
          "type": "navigation"
        },
        {
          "id": "privacy",
          "title": "privacy",
          "icon": "hand.raised.fill",
          "color": "indigo",
          "enabled": false,
          "type": "navigation"
        }
      ]
    },
    {
      "sectionTitle": "connected_accounts",
      "sectionEnabled": false,
      "sectionOptions": [
        {
          "id": "bank_accounts",
          "title": "bank_accounts",
          "icon": "building.columns.fill",
          "color": "blue",
          "enabled": false,
          "type": "navigation",
          "note": "3 contas conectadas"
        },
        {
          "id": "credit_cards",
          "title": "credit_cards",
          "icon": "creditcard.fill",
          "color": "orange",
          "enabled": false,
          "type": "navigation",
          "note": "2 cartões conectados"
        }
      ]
    },
    {
      "sectionTitle": "support",
      "sectionEnabled": true,
      "sectionOptions": [
        {
          "id": "help_center",
          "title": "help_center",
          "icon": "questionmark.circle.fill",
          "color": "blue",
          "enabled": true,
          "type": "navigation"
        },
        {
          "id": "contact",
          "title": "contact",
          "icon": "envelope.fill",
          "color": "green",
          "enabled": false,
          "type": "navigation"
        },
        {
          "id": "about_app",
          "title": "about_app",
          "icon": "info.circle.fill",
          "color": "secondary200",
          "enabled": false,
          "type": "navigation"
        }
      ]
    }
  ]
}
"""
        
        // Converte a string JSON em Data
        guard let data = jsonData.data(using: .utf8) else {
            print("Erro ao converter a string JSON para Data.")
            return
        }
        
        let decoder = JSONDecoder()
        
        do {
            let settings = try decoder.decode(SettingsResponse.self, from: data)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.sections = settings.sections
                self.viewState = .loaded
                self.loadDefaultSelectedValues()
            }
        } catch {
            print("Erro ao decodificar JSON: \(error)")
        }
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
