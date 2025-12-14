//
//  HomeView.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 13/12/25.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedButton: String = "dashboard"
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                switch selectedButton {
                case "dashboard":
                    DashboardView()
                        .navigationTitle(TextValue.dashboard.localized)
                        .task { viewModel.fetchTabs() }
                        .padding(.bottom, 75)
                    
                case "investments":
                    StockWalletView()
                        .navigationTitle(TextValue.dashboardTitle.localized)
                        .navigationBarTitleDisplayMode(.large)
                        .padding(.bottom, 75)
                    
                case "configuration":
                    SettingsView()
                        .navigationTitle(TextValue.settingsTitle.localized)
                        .navigationBarTitleDisplayMode(.large)
                        .padding(.bottom, 75)
                    
                default:
                    EmptyView()
                }
                
                FloatingTabBar(selectedId: $selectedButton, items: viewModel.tabItems)
            }
        }
    }
}
