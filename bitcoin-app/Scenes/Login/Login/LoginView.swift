//
//  LoginView.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 14/12/25.
//

import SwiftUI
import LocalAuthentication
import FirebaseAuth

enum LoginState: Hashable {
    case initial // Opções de login social e demonstração
    case knownUserSocial(userName: String) // Usuário conhecido, sugere login social
    case knownUserBiometric(userName: String) // Usuário conhecido, sugere biometria
    case loggedIn
    case loggedInFirstTime
}

// MARK: - 2. Componentes Reutilizáveis

/// Componente para os botões de login social (Google/Apple).
struct SocialLoginButton: View {
    let title: String
    let iconName: String
    let action: () -> Void
    let isApple: Bool
    
    var body: some View {
        Button(action: action) {
            HStack {
                // Ícone (usando SFSymbols para Apple e um placeholder para Google)
                if isApple {
                    Image(systemName: iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                } else {
                    // Placeholder simples para o ícone do Google
                    Text("G")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.blue)
                        .frame(width: 20, height: 20)
                }
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(isApple ? .white : .black)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isApple ? Color.black : Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - 3. Views de Estado

/// View para o estado inicial (Novo Usuário).
struct InitialLoginView: View {
    @EnvironmentObject var authService: LoginViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Título
            Text("Welcome to App Name")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top, 80)
            
            Text("Your financial journey starts here.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 40)
            
            Spacer()
            
            // Botões de Login Social
            SocialLoginButton(title: "Continue with Google", iconName: "g.circle.fill", action: authService.loginWithGoogle, isApple: false)
            
            SocialLoginButton(title: "Continue with Apple", iconName: "apple.logo", action: authService.loginWithApple, isApple: true)
            
            // Separador
            HStack {
                Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                Text("or").foregroundColor(.gray)
                Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
            }
            .padding(.vertical, 10)
            
            // Botão de Demonstração
            Button(action: authService.enterDemoMode) {
                Text("Ver Demonstração")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 30)
    }
}

/// View para o estado de Usuário Conhecido (Biometria ou Social).
struct KnownUserView: View {
    @EnvironmentObject var authService: LoginViewModel
    let userName: String
    let isBiometric: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // Mensagem de Boas-vindas
            Text("Welcome back,")
                .font(.title)
                .foregroundColor(.gray)
                .padding(.top, 100)
            
            Text(userName)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 40)
            
            Spacer()
            
            if isBiometric {
                // Botão de Biometria
                Button(action: authService.loginWithBiometrics) {
                    HStack {
                        Image(systemName: "touchid") // Ou "faceid"
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                        
                        Text("Sign In with Biometrics")
                            .font(.headline)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 30)
                
            } else {
                // Opções de Login Social para Usuário Conhecido
                VStack(spacing: 15) {
                    SocialLoginButton(title: "Continue with Google", iconName: "g.circle.fill", action: authService.loginWithGoogle, isApple: false)
                    
                    SocialLoginButton(title: "Continue with Apple", iconName: "apple.logo", action: authService.loginWithApple, isApple: true)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
}

/// View de Demonstração (EmptyView solicitada).
struct DemoView: View {
    @EnvironmentObject var authService: LoginViewModel
    
    var body: some View {
        VStack {
            Text("Área Logada (Dados Mockados)")
                .font(.largeTitle)
                .padding()
            
            Text("Esta é a tela X que o usuário veria após o login/demonstração.")
                .foregroundColor(.gray)
            
            Button("Logout") {
                authService.logout()
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }
}


struct LoginScreen: View {
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                switch viewModel.state {
                case .initial:
                    InitialLoginView()
                    
                case .knownUserSocial(let userName):
                    KnownUserView(userName: userName, isBiometric: false)
                    
                case .knownUserBiometric(let userName):
                    KnownUserView(userName: userName, isBiometric: true)
                    
                case .loggedIn:
                    EmptyView()
                    
                case .loggedInFirstTime:
                    OnboardingFlowTemplate()
                }
            }
            .navigationDestination(isPresented: $viewModel.displayHome) { HomeView() }
        }
        .navigationBarBackButtonHidden()
        .environmentObject(viewModel)
    }
}
