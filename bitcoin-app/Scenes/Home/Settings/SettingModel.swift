
import SwiftUI

// Modelo principal que representa a resposta
struct SettingsResponse: Codable {
    let sections: [SectionModel]
}

// Modelo que representa cada seção
struct SectionModel: Codable {
    let sectionTitle: String
    let sectionOptions: [OptionModel]
}

// Modelo que representa cada opção na seção
struct OptionModel: Codable {
    let id: String
    let title: String
    let icon: String
    let color: String
    let enabled: Bool
    let type: String?
    let options: [LanguageOptionModel]? // Para opções de idioma, se houver
}

// Modelo que representa cada opção de idioma
struct LanguageOptionModel: Codable {
    let title: String
    let tag: Int
}

enum ViewState {
    case loading
    case loaded(sections: [SectionModel])
    case failure
}

//        """
//            {
//                "preferences": [
//                    {
//                        "title": "Notificações",
//                        "icon": "bell.fill",
//                        "color": "orange",
//                        "enabled": true,
//                        "type": "toggle"
//                    },
//                    {
//                        "title": "Modo Escuro",
//                        "icon": "moon.fill",
//                        "color": "indigo",
//                        "enabled": false,
//                        "type": "toggle"
//                    },
//                    {
//                        "title": "Linguagem",
//                        "icon": "dollarsign.circle.fill",
//                        "color": "green",
//                        "enabled": true,
//                        "type": "picker",
//                        "options": [
//                            {
//                                "title": "Português",
//                                "tag": 0
//                            },
//                            {
//                                "title": "Inglês",
//                                "tag": 1
//                            }
//                        ]
//                    }
//                ]
//            }
//            """
