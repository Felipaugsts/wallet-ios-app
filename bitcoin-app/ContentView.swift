import SwiftUI

struct ContentView: View {
    @EnvironmentObject var languageManager: LocalizationManager
    
    var body: some View {
        TabView {
            VStack {
                StockWalletDashboard()
            }
            .tabItem {
                Label("Dashboard", systemImage: "list.bullet.rectangle.fill")
            }
            
            SettingsView()
                .tabItem {
                    Label("Configurações", systemImage: "gearshape.fill")
                }
        }
        .accentColor(ColorPalette.primary)
    }
}

//#Preview {
//    ContentView()
//}
