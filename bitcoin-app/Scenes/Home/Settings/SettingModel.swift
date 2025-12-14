
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

extension SettingsResponse {
    static func mock() -> SettingsResponse {
        return SettingsResponse(sections: [
            SectionModel(
                sectionTitle: "preferences",
                sectionEnabled: true,
                sectionOptions: [
                    OptionModel(
                        id: "mockTest",
                        title: "mockTest",
                        icon: "bell.fill",
                        color: "green",
                        enabled: false,
                        type: .toggle,
                        options: nil
                    ),
                    OptionModel(
                        id: "mockTest",
                        title: "mockTest",
                        icon: "bitcoinsign.bank.building.fill",
                        color: "yellow",
                        enabled: false,
                        type: .toggle,
                        options: nil
                    ),
                    OptionModel(
                        id: "mockTest",
                        title: "mockTest",
                        icon: "moon.fill",
                        color: "indigo",
                        enabled: false,
                        type: .toggle,
                        options: nil
                    ),
                    OptionModel(
                        id: "mockTest",
                        title: "mockTest",
                        icon: "dollarsign.circle.fill",
                        color: "green",
                        enabled: false,
                        type: .picker,
                        options: []
                    )
                ]
            ),
            SectionModel(
                sectionTitle: "security_and_privacy",
                sectionEnabled: true,
                sectionOptions: [
                    OptionModel(
                        id: "biometric_auth",
                        title: "biometric_auth",
                        icon: "faceid",
                        color: "blue",
                        enabled: false,
                        type: .toggle,
                        options: nil
                    ),
                    OptionModel(
                        id: "change_password",
                        title: "change_password",
                        icon: "lock.fill",
                        color: "red",
                        enabled: false,
                        type: .navigation,
                        options: nil
                    ),
                    OptionModel(
                        id: "privacy",
                        title: "privacy",
                        icon: "hand.raised.fill",
                        color: "indigo",
                        enabled: false,
                        type: .navigation,
                        options: nil
                    )
                ]
            )
        ])
    }
}
