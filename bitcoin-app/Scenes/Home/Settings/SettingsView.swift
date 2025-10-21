//
//  SettingsView.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 12/10/25.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    
    
    var body: some View {
        
        VStack {
            switch viewModel.viewState {
            case .loading:
                Text("Loading")
                
            case .failure:
                Text("Failure")
                
            case .loaded(let sections):
                loadedValues(sections: sections)
            }
        }
        .onAppear {
            viewModel.fetchData()
        }
    }
    
    @ViewBuilder
    func loadedValues(sections: [SectionModel]) -> some View {
        NavigationView {
            List {
                ForEach(sections, id: \.sectionTitle) { section in
                    Section(header: Text(section.sectionTitle)) {
                        ForEach(section.sectionOptions, id: \.id) { item in // Usar 'id' para o ForEach
                            HStack {
                                Image(systemName: item.icon)
                                    .foregroundColor(Color(item.color))
                                    .frame(width: 28)
                                
                                switch item.type {
                                case "toggle":
                                    Toggle("\(item.title)".localized, isOn: viewModel.setBinding(for: item.id))
                                        .disabled(!item.enabled)
                                case "picker":
                                    if let pickerOptions = item.options {
                                        Picker("\(item.title)".localized, selection: viewModel.pickerBinding(for: item.id)) {
                                            ForEach(pickerOptions, id: \.tag) { option in
                                                Text(option.title).tag(option.tag)
                                            }
                                        }
                                        .disabled(!item.enabled)
                                    }
                                    
                                case "navigation":
                                    NavigationLink(destination: Text("\(item.title)".localized)) { // Destino do NavigationLink
                                        Text(item.title)
                                    }.disabled(!item.enabled)
                                    
                                default:
                                    EmptyView() // Para qualquer tipo desconhecido
                                }
                            }
                        }
                    }
                }
                
                // Seção para Sair
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
                
                // Seção para Versão do App
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
            .navigationTitle("configuration".localized)
        }
        .refreshable {
            viewModel.fetchData()
        }
    }
}


