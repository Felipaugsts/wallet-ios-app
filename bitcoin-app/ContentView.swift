//
//  ContentView.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 11/10/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.pie.fill")
                }
                .tag(0)
            
            TransactionsView()
                .tabItem {
                    Label("Transações", systemImage: "list.bullet.rectangle.fill")
                }
                .tag(1)
            
            GoalsView()
                .tabItem {
                    Label("Metas", systemImage: "target")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("Configurações", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .accentColor(.blue)
    }
}
