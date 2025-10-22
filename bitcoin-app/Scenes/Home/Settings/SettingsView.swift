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
                ProgressView()
                
            case .failure:
                ContentUnavailableView(LocalizedStringKey(stringLiteral: "Something went wrong"), systemImage: "")
                
            case .loaded:
                loadedValues(sections: viewModel.sections)
            }
        }
        .task {
            viewModel.fetchData()
        }
    }
    
    @ViewBuilder
    func loadedValues(sections: [SectionModel]) -> some View {
        NavigationView {
            List {
                ForEach(sections, id: \.sectionTitle) { section in
                    if section.sectionEnabled {
                        Section(header: Text(section.sectionTitle.localized)) {
                            ForEach(section.sectionOptions, id: \.id) { item in // Usar 'id' para o ForEach
                                loadedComponent(item: item)
                            }
                        }
                    }
                }
                fixedSections()
            }
            .navigationTitle("configuration".localized)
        }
        .refreshable {
            viewModel.fetchData()
        }
    }
}

// MARK: - View Builders

extension SettingsView {
    @ViewBuilder
    func loadedComponent(item: OptionModel) -> some View {
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
                            Text("\(option.title)".localized).tag(option.tag)
                        }
                    }
                    .disabled(!item.enabled)
                }
                
            case "navigation":
                NavigationLink(destination: Text("\(item.title)".localized)) { // Destino do NavigationLink
                    Text("\(item.title)".localized)
                }.disabled(!item.enabled)
                
            default:
                EmptyView()
            }
        }
        
    }
    
    @ViewBuilder
    func fixedSections() -> some View {
        Section {
            Button(action: {
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
