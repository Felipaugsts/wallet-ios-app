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
            switch viewModel.viewState {
            case .loading:
                ProgressView()
                
            case .failure:
                ContentUnavailableView(LocalizedStringKey(stringLiteral: "Something went wrong"), systemImage: "")
                
            case .loaded:
                loadedValues(sections: viewModel.sections)
            }
        }
        .task { viewModel.fetchData() }
        .scrollBounceBehavior(.basedOnSize)
        .scrollIndicators(.hidden)
    }
    
    @ViewBuilder
    func loadedValues(sections: [SectionModel]) -> some View {
        List {
            ForEach(sections, id: \.sectionTitle) { section in
                if section.sectionEnabled {
                    Section(header: Text(section.sectionTitle.localized)) {
                        ForEach(section.sectionOptions, id: \.id) { item in
                            sectionsCards(item: item)
                        }
                    }
                }
            }
            
            fixedSections()
        }
    }
}
