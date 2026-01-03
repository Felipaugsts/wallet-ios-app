//
//  HomeView.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 13/12/25.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedButton: String = "dashboard"
    @State private var disabled: Bool = false
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        ZStack {
            currentView()
                .navigationBarBackButtonHidden()
                .scrollBounceBehavior(.basedOnSize)
            
            FloatingTabBar(selectedId: $selectedButton, items: viewModel.tabItems)
                .disabled(disabled)
                .shimmer(when: $viewModel.isLoading)
        }
        .task { viewModel.fetchTabs() }
        .navigationBarBackButtonHidden()
        .scrollBounceBehavior(.basedOnSize)
    }
    
    @ViewBuilder
    private func currentView() -> some View {
        switch selectedButton {
        case "dashboard":
            DashboardView()
                .navigationTitle(TextValue.dashboard.localized)
                .task { viewModel.fetchTabs() }
                
        case "investments":
            StockWalletView()
                .navigationTitle(TextValue.dashboardTitle.localized)
                .navigationBarTitleDisplayMode(.large)
            
        case "configuration":
            SettingsView(disabled: $disabled)
                .navigationTitle(TextValue.settingsTitle.localized)
                .navigationBarTitleDisplayMode(.large)
            
        default:
            EmptyView()
        }
    }
}
