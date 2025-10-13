import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Wallet", systemImage: "bitcoinsign.circle.fill")
                }
            
            CryptoTransactionsView(transactions: CryptoTransaction.sampleTransactions)
                .tabItem {
                    Label("Transações", systemImage: "list.bullet.rectangle.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Configurações", systemImage: "gearshape.fill")
                }
        }
        .accentColor(.blue)
    }
}

#Preview {
    ContentView()
}
