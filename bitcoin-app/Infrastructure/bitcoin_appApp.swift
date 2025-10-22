//
//  bitcoin_appApp.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 11/10/25.
//

import SwiftUI

@main
struct bitcoin_appApp: App {
    @StateObject var languageManager = LocalizationManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(languageManager)
                .environment(\.locale, languageManager.language.locale)
        }
    }
}
