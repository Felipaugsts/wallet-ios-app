//
//  LaunchView.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 14/12/25.
//

import SwiftUI
import FirebaseAuth

struct SplashScreen: View {
    @State private var displayLogin = false
    @State private var displayHome = false
    @State private var isVisible = false
    @State private var buttonOffset: CGFloat = 100
    @State private var isButtonVisible = false
    @State private var isSplashVisible = true
    @StateObject private var viewModel = LoginViewModel()
    
    var isBiometryEnabled = UserRepository.shared.isBiometricEnabled
    private var authListener: AuthStateDidChangeListenerHandle?
    
    @AppStorage(.onboardingKey) internal var isOnboardingCompleted: Bool = false
    @AppStorage(.updatedDahboardKey) internal var updateTransactions: Bool = true
    
    var body: some View {
        NavigationStack {
            VStack {
                if isSplashVisible {
                    VStack {
                        if isVisible {
                            Image("logo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .transition(.opacity)
                        }
                        
                        Text("Finance App")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top, 10)
                    }
                    
                    Text("Welcome")
                }
                
                if isButtonVisible {
                    VStack(spacing: 20) {
                        VStack {
                            Text("Welcome back,")
                                .font(.title)
                                .foregroundColor(.gray)
                                .padding(.top, 100)
                            
                            Text("Felipe Augusto")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.bottom, 40)
                        }
                        .offset(y: -buttonOffset)
                        .animation(.easeInOut(duration: 0.5), value: buttonOffset)
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.loginWithBiometrics()
                        }) {
                            HStack {
                                Image(systemName: "touchid")
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
                        .offset(y: buttonOffset)
                        .animation(.easeInOut(duration: 0.5), value: buttonOffset)
                        
                    }
                }
            }
            .navigationDestination(isPresented: $displayHome) { HomeView() }
            .navigationDestination(isPresented: $displayLogin) { LoginScreen() }
            .onChange(of: viewModel.displayHome, { displayHome = true })
            .onAppear {
                updateTransactions = true
                
                if isOnboardingCompleted {
                    isSplashVisible = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.7) {
                    self.setupAuthListener()
                }
                
                withAnimation(.easeIn(duration: 1)) { isVisible = true }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                    if !isOnboardingCompleted {
                        setupAuthListener()
                    }
                }
            }
        }
    }
    
    private func displayLoggedInAnimation() {
        withAnimation(.easeOut(duration: 0.3)) {
            isVisible = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation() {
                isSplashVisible = false
                isButtonVisible = true
            }
            
            
            withAnimation(.easeIn(duration: 0.8)) {
                buttonOffset = -20
            }
        }
    }
    
    private func displayWithAnimation(login: Bool = false) {
        withAnimation(.easeOut(duration: 0.3)) {
            isVisible = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            if login {
                self.displayLogin = true
            } else {
                self.displayHome = true
            }
        }
    }
    
    @MainActor
    private func setupAuthListener() {
        _ = Auth.auth().addStateDidChangeListener { authResult, user in
            if let user = user {
                let userModel = User(id: user.uid, name: user.displayName ?? "", email: user.email ?? "", photoURL: user.photoURL)
                
                if UserRepository.shared.saveUser(userModel) {
                    if !UserRepository.shared.isBiometricEnabled {
                        displayWithAnimation()
                    } else {
                        displayLoggedInAnimation()
                    }
                }
            } else {
                displayWithAnimation(login: true)
            }
        }
    }
}
