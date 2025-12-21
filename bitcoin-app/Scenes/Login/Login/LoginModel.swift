//
//  LoginModel.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 21/12/25.
//

enum LoginModel {
    struct Config: Codable {
        var loginWithGoogle: Bool
        var loginWithApple: Bool
        var demo: Bool
    }
}
