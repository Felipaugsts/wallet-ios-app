//
//  RemoteConfigService.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 13/12/25.
//

import Foundation
import Firebase
import SwiftUI

import Foundation
import Firebase

class RemoteConfigManager {
    
    static let shared = RemoteConfigManager()
    
    private let remoteConfig: RemoteConfig
    
    // Inicializador
    init(remoteConfig: RemoteConfig = .remoteConfig()) {
        self.remoteConfig = remoteConfig
        let settings = RemoteConfigSettings()
        
        // Defina minimumFetchInterval para 0 durante o desenvolvimento
        settings.minimumFetchInterval = 0 // Sempre fetch
        self.remoteConfig.configSettings = settings
        
        // Configuração dos valores padrão
        self.remoteConfig.setDefaults([
            "wp_configuration_view": "default value" as NSObject
        ])
    }
    
    // Método para buscar e ativar configurações
    func fetchAndActivate() {
        remoteConfig.fetchAndActivate { status, error in
            if let error = error {
                print("⚠️ Erro ao buscar: \(error.localizedDescription)")
                return
            }
            print("Configurações remotas ativadas com sucesso: \(status)")
        }
    }
    
    // Métodos para acessar os valores
    func bool(for key: RemoteConfigKeys) -> Bool {
        return remoteConfig[key.rawValue].boolValue
    }
    
    func string(for key: RemoteConfigKeys) -> String {
        return remoteConfig[key.rawValue].stringValue
    }
    
    func int(for key: RemoteConfigKeys) -> Int {
        return remoteConfig[key.rawValue].numberValue.intValue
    }
    
    func model<T: Codable>(model: T.Type, for key: RemoteConfigKeys) -> T? {
        guard let json = remoteConfig.configValue(forKey: key.rawValue).stringValue.data(using: .utf8) else { return nil }
        return json.parseAs(model)
    }
}

// Enum para as chaves de configuração remota
enum RemoteConfigKeys: String {
    case configurationView = "wp_configuration_view"
    case tabConfiguration = "wp_tabview_config"
    case wpCategories = "wp_categories"
    case recurringEnabled = "wp_recurring_enabled"
    case onboardingConfig = "wp_onboarding_config"
    case loginConfig = "wp_login_config"
}

extension Data {

    func parseAs<T: Decodable>(_ model: T.Type) -> T? {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = PixNetworking.shared.dateDecodingStrategy
            return try decoder.decode(T.self, from: self)
        }
        catch DecodingError.dataCorrupted(let context) {
            print("mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
             return nil
        } catch DecodingError.keyNotFound(let key, let context) {
            print("key '\(key)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
             return nil
        } catch DecodingError.typeMismatch(let type, let context) {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
             return nil
        } catch  DecodingError.valueNotFound(let value, let context) {
            print("value '\(value)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
             return nil
        } catch {
            return nil
        }
    }
}

class PixNetworking {
    public static let shared = PixNetworking()
    public var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .custom({ (decoder) -> Date in
        let container = try decoder.singleValueContainer()
        let dateStr = try container.decode(String.self)
        return dateStr.dateFromISO8601()
    })
}

extension String {
    func dateFromISO8601() -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(identifier: "America/Sao_Paulo")
        formatter.formatOptions = [.withDay, .withMonth, .withYear, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        guard let dateAndTime = formatter.date(from: self) else { return toDate(withFormat: "yyyy-MM-dd") }
        return dateAndTime
    }
    
    func toDate(withFormat format: String = "dd/MM/yyyy") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "America/Sao_Paulo")
        dateFormatter.dateFormat = format
        guard let date = dateFormatter.date(from: self) else { return Date() }
        return date
    }
}
