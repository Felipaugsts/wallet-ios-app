
import SwiftUI

// Modelo principal que representa a resposta
struct SettingsResponse: Codable {
    let sections: [SectionModel]
}

// Modelo que representa cada seção
struct SectionModel: Codable {
    let sectionTitle: String
    let sectionEnabled: Bool
    let sectionOptions: [OptionModel]
}

// Modelo que representa cada opção na seção
struct OptionModel: Codable {
    let id: String
    let title: String
    let icon: String
    let color: String
    let enabled: Bool
    let type: switchTypes?
    let options: [LanguageOptionModel]? // Para opções de idioma, se houver
}

// Modelo que representa cada opção de idioma
struct LanguageOptionModel: Codable {
    let title: String
    let tag: Int
}

enum ViewState {
    case loading
    case loaded
    case failure
}

enum switchTypes: String, Codable {
    case picker = "picker"
    case navigation = "navigation"
    case toggle = "toggle"
}
