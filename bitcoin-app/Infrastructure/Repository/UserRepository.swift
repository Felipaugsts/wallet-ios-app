//
//  UserRepository.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 14/12/25.
//

import Foundation
import Security
import FirebaseAuth

struct User: Codable {
    let id: String
    let name: String
    let email: String
    let photoURL: URL?
}

class UserRepository {
    
    private let keychainService = KeychainService()
    private let serviceIdentifier = "com.seuapp.user"
    private let accountIdentifier = "userAccount"
    var isBiometricEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "isBiometricEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "isBiometricEnabled") }
    }
    
    static var shared = UserRepository()
    
    func saveUser(_ user: User) -> Bool {
        guard let userData = try? JSONEncoder().encode(user) else {
            return false
        }
        return keychainService.save(service: serviceIdentifier, account: accountIdentifier, data: userData)
    }
    
    // Carrega o usuário do Keychain
    func loadUser() -> User? {
        guard let userData = keychainService.load(service: serviceIdentifier, account: accountIdentifier) else {
            return nil
        }
        return try? JSONDecoder().decode(User.self, from: userData)
    }
    
    // Remove o usuário do Keychain
    func logout() {
        do {
            try Auth.auth().signOut()
            _ = keychainService.delete(service: serviceIdentifier, account: accountIdentifier)
        } catch {
            print("error")
        }
    }
}


class KeychainService {
    
    // Método para salvar dados no Keychain
    @discardableResult
    func save(service: String, account: String, data: Data) -> Bool {
        // Remove qualquer item existente
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ] as [String : Any]
        
        SecItemDelete(query as CFDictionary)
        
        // Adiciona novo item
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    // Método para carregar dados do Keychain
    func load(service: String, account: String) -> Data? {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as [String : Any]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecSuccess {
            return item as? Data
        } else {
            return nil
        }
    }
    
    // Método para remover dados do Keychain
    @discardableResult
    func delete(service: String, account: String) -> Bool {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ] as [String : Any]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}
