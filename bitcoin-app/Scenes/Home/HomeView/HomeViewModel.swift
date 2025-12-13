//
//  HomeViewModel.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 13/12/25.
//


import Foundation

class HomeViewModel: ObservableObject {
    @Published var isLoading = true
    @Published var tabItems: [TabItem] = []
    
    func fetchTabs() {
        let tabs = RemoteConfigManager.shared.model(model: TabBarConfiguration.self, for: .tabConfiguration)
        
        if let remoteConfigTabs = tabs?.items {
            tabItems = remoteConfigTabs
        } else {
            tabItems = []
        }
        
        isLoading = false
    }
}
