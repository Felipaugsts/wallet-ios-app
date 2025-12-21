//
//  LoginViewModel.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 14/12/25.
//
import Foundation
import FirebaseAuth
import GoogleSignIn
import SwiftUI
import LocalAuthentication
import FirebaseCore

class LoginViewModel: ObservableObject {
    @Published var state: LoginState = {
        if let user = UserRepository.shared.loadUser() {
            return .knownUserSocial(userName: user.name)
        }
        
        return .initial
    }()
    
    @Published var displayHome = false
    private var userRepository = UserRepository.shared
    private var user = UserRepository.shared.loadUser()
    private let biometryEnabled: Bool = UserRepository.shared.isBiometricEnabled
    
    var remoteConfig: LoginModel.Config? {
        RemoteConfigManager.shared.model(model: LoginModel.Config.self, for: .loginConfig)
    }
    
    init() {
        // Lógica para determinar o estado inicial
        if let user = user?.name {
            state = .knownUserBiometric(userName: user)
        } else {
            state = .initial
        }
    }
    
    // MARK: - Ações de Login Mockadas
    
    func loginWithGoogle() {
        Task {
            do {
                try await googleOauth()
            } catch {
                
            }
        }
    }
    
    func googleOauth() async throws {
        // google sign in
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("no firbase clientID found")
        }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        //get rootView
        let scene = await UIApplication.shared.connectedScenes.first as? UIWindowScene
        guard let rootViewController = await scene?.windows.first?.rootViewController
        else {
            fatalError("There is no root view controller!")
        }
        
        //google sign in authentication response
        let result = try await GIDSignIn.sharedInstance.signIn(
            withPresenting: rootViewController
        )
        let user = result.user
        guard let idToken = user.idToken?.tokenString else {
            throw AuthenticationError.runtimeError("Unexpected error occurred, please retry")
        }
        
        //Firebase auth
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken, accessToken: user.accessToken.tokenString
        )
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("Erro ao autenticar no Firebase: \(error.localizedDescription)")
                return
            }
            guard let user = authResult?.user else { return }
            let userModel = User(id: user.uid, name: user.displayName ?? "", email: user.email ?? "", photoURL: user.photoURL)
            
            print("userModel:", userModel)
            if self.userRepository.saveUser(userModel) {
                self.state = .loggedInFirstTime
            }
        }
    }
    @AppStorage(.onboardingKey) private var isOnboardingCompleted = false
    
    func loginWithApple() {
        isOnboardingCompleted = false

    }
    
    func loginWithBiometrics() {
        print("Tentativa de login com Biometria...")
        // Apenas simula a chamada de uma função de biometria
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Para acessar sua conta de finanças.") { success, error in
                if success {
                    self.displayHome = true
                }
            }
        }
    }
    
    func enterDemoMode() {
        print("Entrando no modo de demonstração (dados mockados)...")
        // Simula acesso à área logada com dados mockados
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.state = .loggedIn
        }
    }
    
    func logout() {
        // Simula logout
        state = .initial
    }
    
    func switchToInitialLogin() {
        state = .initial
    }
}

enum AuthenticationError: Error {
    case runtimeError(String)
}
