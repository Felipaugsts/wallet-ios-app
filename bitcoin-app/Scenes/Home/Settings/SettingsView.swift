//
//  SettingsView.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 12/10/25.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject var viewModel = SettingsViewModel()
    @EnvironmentObject var languageManager: LocalizationManager
    
    var body: some View {
        VStack {
            List {
                ForEach(viewModel.sections, id: \.sectionTitle) { section in
                    if section.sectionEnabled {
                        Section(header: Text(section.sectionTitle.localized)) {
                            ForEach(section.sectionOptions, id: \.id) { item in
                                sectionsCards(item: item)
                                    .shimmer(when: $viewModel.isLoading)
                            }
                        }
                    }
                }
                
                fixedSections()
                    .shimmer(when: $viewModel.isLoading)
            }
            
            VStack {}.frame(height: 50)
        }
        .task { viewModel.fetchData() }
        .scrollBounceBehavior(.basedOnSize)
        .scrollIndicators(.hidden)
        .navigationDestination(isPresented: $viewModel.didLogOut) {
            LoginScreen()
        }
    }
    
    @ViewBuilder
    func fixedSections() -> some View {
        Section {
            Button(action: {
                viewModel.logout()
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
}
