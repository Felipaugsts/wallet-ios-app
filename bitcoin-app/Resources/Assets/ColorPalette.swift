//
//  ColorPalette.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 20/10/25.
//

import SwiftUI

enum AvailableThemes {
    case light
    case dark
}

class ThemeManager {
    static var shared = ThemeManager()
    
    var theme: AvailableThemes = .dark
    
    func updateTheme(_ theme: AvailableThemes) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.overrideUserInterfaceStyle = theme == .dark ? .dark : .light
        }
        
        if theme == self.theme { return }
        self.theme = theme
        UserDefaultsUtils.shared.setDarkMode(enable: theme == .dark)
    }
}

struct ColorPalette {
    static var primary = Color("primary")
    static var secondary100 = Color("secondary100")
    static var secondary200 = Color("secondary200")
    static var backgroundView = Color("backgroundView")
    static var backgroundView200 = Color("backgroundView200")
    static var orange = Color("orange")
    static var indigo = Color("indigo")
    static var green = Color("green")
    static var blue = Color("blue")
    static var red = Color("red")
    static var light = Color("light")
    static var disabled = Color("disabled")
    static var yellow = Color("yellow")
    static var black = Color("black")
    static var purple = Color("purple")
    static var textColor = Color ("textColor")
}
