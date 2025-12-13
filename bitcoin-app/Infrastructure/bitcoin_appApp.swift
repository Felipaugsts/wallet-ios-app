//
//  bitcoin_appApp.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 11/10/25.
//

import SwiftUI
import FirebaseCore

@main
struct bitcoin_appApp: App {
    @StateObject var languageManager = LocalizationManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(languageManager)
                .environment(\.locale, languageManager.language.locale)
                .onAppear {
                    FirebaseApp.configure()
                    RemoteConfigManager.shared.fetchAndActivate()
                    setupTheme()
                }
        }
    }
    
    private func setupTheme() {
        let isDarkMode = UserDefaultsUtils.shared.getDarkMode()
        ThemeManager.shared.updateTheme(isDarkMode ? .dark : .light)
    }
}
