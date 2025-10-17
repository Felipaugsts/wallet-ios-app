//
//  SettingsView.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 12/10/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var biometricAuthEnabled = true
    @State private var darkModeEnabled = false
    @State private var selectedLanguage: Int = LocalizationManager.shared.language == .english ? 1 : 0

    var body: some View {
        NavigationView {
            List {
                
                // Seção de Preferências
                Section(header: Text("Preferências")) {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.orange)
                            .frame(width: 28)
                        Toggle("Notificações", isOn: $notificationsEnabled)
                    }
                    
                    HStack {
                        Image(systemName: "moon.fill")
                            .foregroundColor(.indigo)
                            .frame(width: 28)
                        Toggle("Modo Escuro", isOn: $darkModeEnabled)
                    }
                    
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.green)
                            .frame(width: 28)
                        Picker("language".localized, selection: $selectedLanguage) {
                            Text("portuguese".localized).tag(0)
                            Text("english".localized).tag(1)
                        }
                    }
                    .onChange(of: selectedLanguage) { newValue in
                             print("Selected language index: \(newValue)")
                             // Atualize a configuração de linguagem aqui, se necessário
                             if newValue == 0 {
                                 // Ação para português
                                 LocalizationManager.shared.language = .portuguese
                             } else {
                                 // Ação para inglês
                                 LocalizationManager.shared.language = .english
                             }
                         }
                }
                
                // Seção de Segurança
                Section(header: Text("Segurança e Privacidade")) {
                    HStack {
                        Image(systemName: "faceid")
                            .foregroundColor(.blue)
                            .frame(width: 28)
                        Toggle("Autenticação Biométrica", isOn: $biometricAuthEnabled)
                    }
                    
                    NavigationLink(destination: Text("Alterar Senha")) {
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.red)
                                .frame(width: 28)
                            Text("Alterar Senha")
                        }
                    }
                    
                    NavigationLink(destination: Text("Privacidade")) {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                                .foregroundColor(.purple)
                                .frame(width: 28)
                            Text("Privacidade")
                        }
                    }
                }
                
                // Seção de Contas Conectadas
                Section(header: Text("Contas Conectadas")) {
                    NavigationLink(destination: Text("Gerenciar Contas")) {
                        HStack {
                            Image(systemName: "building.columns.fill")
                                .foregroundColor(.blue)
                                .frame(width: 28)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Contas Bancárias")
                                    .font(.body)
                                Text("3 contas conectadas")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    NavigationLink(destination: Text("Gerenciar Cartões")) {
                        HStack {
                            Image(systemName: "creditcard.fill")
                                .foregroundColor(.orange)
                                .frame(width: 28)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Cartões de Crédito")
                                    .font(.body)
                                Text("2 cartões conectados")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                // Seção de Dados
                Section(header: Text("Dados")) {
                    NavigationLink(destination: Text("Exportar Dados")) {
                        HStack {
                            Image(systemName: "square.and.arrow.up.fill")
                                .foregroundColor(.blue)
                                .frame(width: 28)
                            Text("Exportar Dados")
                        }
                    }
                    
                    NavigationLink(destination: Text("Importar Dados")) {
                        HStack {
                            Image(systemName: "square.and.arrow.down.fill")
                                .foregroundColor(.green)
                                .frame(width: 28)
                            Text("Importar Dados")
                        }
                    }
                    
                    Button(action: {
                        // Ação para fazer backup
                    }) {
                        HStack {
                            Image(systemName: "icloud.and.arrow.up.fill")
                                .foregroundColor(.blue)
                                .frame(width: 28)
                            Text("Fazer Backup")
                                .foregroundColor(.primary)
                        }
                    }
                }
                
                // Seção de Suporte
                Section(header: Text("Suporte")) {
                    NavigationLink(destination: Text("Central de Ajuda")) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(.blue)
                                .frame(width: 28)
                            Text("Central de Ajuda")
                        }
                    }
                    
                    NavigationLink(destination: Text("Contato")) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.green)
                                .frame(width: 28)
                            Text("Entrar em Contato")
                        }
                    }
                    
                    NavigationLink(destination: Text("Sobre")) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.gray)
                                .frame(width: 28)
                            Text("Sobre o App")
                        }
                    }
                }
                
                // Seção de Conta
                Section {
                    Button(action: {
                        // Ação para sair
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                                .frame(width: 28)
                            Text("Sair")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                // Versão do App
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 4) {
                            Text("Finanças Pessoais")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Versão 1.0.0")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Configurações")
        }
    }
}
