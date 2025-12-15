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
    private var authListener: AuthStateDidChangeListenerHandle?

    var body: some View {
        NavigationStack {
            VStack {
                ProgressView()
                    .task {
                        setupAuthListener()
                    }.edgesIgnoringSafeArea(.all)
            }
            .navigationDestination(isPresented: $displayHome) { HomeView() }
            .navigationDestination(isPresented: $displayLogin) { LoginScreen() }
        }
    }

    private func setupAuthListener() {
        _ = Auth.auth().addStateDidChangeListener { authResult, user in
            if let user = user {
                let userModel = User(id: user.uid, name: user.displayName ?? "", email: user.email ?? "", photoURL: user.photoURL)

                if UserRepository.shared.saveUser(userModel) {
                    if !UserRepository.shared.isBiometricEnabled {
                        displayHome = true
                    } else {
                        displayLogin = true
                    }
                }
            } else {
                displayLogin = true
            }
        }
    }
}

