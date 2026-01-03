//
//  SettingsView.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 12/10/25.
//

import SwiftUI

struct SettingsView: View {
    @Binding var disabled: Bool
    @StateObject var viewModel = SettingsViewModel()
    @EnvironmentObject var languageManager: LocalizationManager
    
    var body: some View {
        VStack {
            List {
                if let user = viewModel.user {
                    HStack {
                        AsyncImage(url: user.photoURL) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .shadow(radius: 10)
                        } placeholder: {
                            Circle()
                                .fill(ColorPalette.light)
                                .frame(width: 50, height: 50)
                                .shadow(color: .black.opacity(0.0205), radius: 1)
                                .shimmer(when: .constant(true))
                        }
                        
                        Text(user.name)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 10)
                    }
                }
                
                ForEach(viewModel.sections, id: \.sectionTitle) { section in
                    if section.sectionEnabled {
                        Section(header: Text(section.sectionTitle.localized)) {
                            ForEach(section.sectionOptions, id: \.id) { item in
                                if item.visible {
                                    sectionsCards(item: item)
                                        .shimmer(when: $viewModel.isLoading)
                                }
                            }
                        }
                    }
                }
                
                fixedSections()
                    .shimmer(when: $viewModel.isLoading)

                Section {
                        HStack {}
                        .frame(height: 50)
                        .background(Color(uiColor: .systemGroupedBackground))
                }
            }
        }
        .task { viewModel.fetchData() }
        .disabled(!viewModel.screenEnabled)
        .scrollIndicators(.hidden)
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationDestination(isPresented: $viewModel.didLogOut) {
            LoginScreen()
        }
        .padding(.top, 15)
        .loadingView(isLoading: viewModel.springLoading)
    }
    
    @ViewBuilder
    func fixedSections() -> some View {
        Section {
            Button(action: {
                disabled = true
                viewModel.logout()
            }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.red)
                        .frame(width: 28)
                    Text("logout".localized)
                        .foregroundColor(.red)
                }
            }
        }
    }
}

struct ContactView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var message: String = ""
    @State private var showMessageSent: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 16) {
                TextEditor(text: $message)
                    .frame(height: 150)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.105), radius: 2)
                
                Button(action: {
                    // Ação para enviar a mensagem
                    showMessageSent = true
                    print("Mensagem enviada: \(message) de \(name) (\(email))")
                }) {
                    Text("Enviar Mensagem")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .font(.headline)
                }
                .alert(isPresented: $showMessageSent) {
                    Alert(
                        title: Text("Mensagem Enviada"),
                        message: Text("Sua mensagem foi enviada com sucesso!"),
                        dismissButton: .default(Text("OK"))
                    )
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Entrar em Contato")
        }
        
    }
}

struct AboutView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    Text("Este aplicativo de finanças pessoais ajuda você a gerenciar suas despesas, economizar dinheiro e planejar seu futuro financeiro. Com uma interface simples e intuitiva, você pode acompanhar suas finanças de forma eficaz.")
                        .font(.body)
                        .foregroundColor(.gray)
                    
                    Text("Recursos principais:")
                        .font(.headline)
                    
                    VStack(alignment: .leading) {
                        ForEach([
                            "Controle de despesas",
                            "Orçamento mensal",
                            "Relatórios de gastos",
                            "Dicas de economia"
                        ], id: \.self) { feature in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(feature)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .scrollBounceBehavior(.basedOnSize)
            .navigationTitle("Sobre o App")
        }
    }
}


import SwiftUI

// Modificador para mostrar um loading centralizado
struct LoadingModifier: ViewModifier {
    var isLoading: Bool
    var loadingText: String = "Carregando..." // Texto opcional para o loading

    func body(content: Content) -> some View {
        ZStack {
            content

            if isLoading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()

                ProgressView(loadingText)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5, anchor: .center)
                    .foregroundColor(.white)
            }
        }
    }
}

extension View {
    func loadingView(isLoading: Bool, loadingText: String = "") -> some View {
        self.modifier(LoadingModifier(isLoading: isLoading, loadingText: loadingText))
    }
}
