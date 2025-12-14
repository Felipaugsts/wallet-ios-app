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
        }
        .task { viewModel.fetchData() }
        .scrollBounceBehavior(.basedOnSize)
        .scrollIndicators(.hidden)
    }
}
