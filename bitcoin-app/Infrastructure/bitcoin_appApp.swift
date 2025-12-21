//
//  bitcoin_appApp.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 11/10/25.
//

import SwiftUI
import FirebaseCore
import Firebase
import GoogleSignIn

@main
struct bitcoin_appApp: App {
    @StateObject var languageManager = LocalizationManager.shared
    @AppStorage(.onboardingKey) private var isOnboardingCompleted = false
    
    var body: some Scene {
        WindowGroup {
            SplashScreen()
                .environment(languageManager)
                .environment(\.locale, languageManager.language.locale)
                .onOpenURL(perform: { url in GIDSignIn.sharedInstance.handle(url) } )
                .onAppear { configureApp() }
        }
    }
    
    // MARK: - Private Methods
    
    private func configureApp() {
        FirebaseApp.configure()
        RemoteConfigManager.shared.fetchAndActivate()
        setupTheme()
        setupLanguage()
    }
    
    private func setupTheme() {
        let isDarkMode = UserDefaultsUtils.shared.getDarkMode()
        ThemeManager.shared.updateTheme(isDarkMode ? .dark : .light)
    }
    
    private func setupLanguage() {
        let language = UserDefaultsUtils.shared.getLanguage()
        languageManager.saveLanguage(SelectedLanguage(rawValue: language) ?? .english)
    }
}


struct FeatureInfos: Codable {
    let image: String
    let title: String
    let content: String
}

struct FinanceApp: Codable {
    let appDisplayName: String
    let appIcon: String
    let features: [FeatureInfos]
    let privacyPolicyURL: URL
}


