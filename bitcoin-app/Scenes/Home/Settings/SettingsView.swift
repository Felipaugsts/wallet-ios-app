import SwiftUI

struct SettingsView: View {
    @State private var xpubKey: String = ""
    @State private var enableNotifications: Bool = true
    @State private var biometricAuthEnabled: Bool = true
    @State private var selectedCurrency: Int = 0 // 0 for USD, 1 for BRL, etc.
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Configurações da Carteira")) {
                    TextField("Chave Pública Estendida (xpub)", text: $xpubKey)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    Picker("Moeda de Exibição", selection: $selectedCurrency) {
                        Text("USD ($)").tag(0)
                        Text("BRL (R$)").tag(1)
                        Text("EUR (€)").tag(2)
                    }
                }
                
                Section(header: Text("Segurança")) {
                    Toggle(isOn: $biometricAuthEnabled) {
                        Text("Autenticação Biométrica")
                    }
                    NavigationLink(destination: Text("Alterar Senha")) {
                        Text("Alterar Senha")
                    }
                }
                
                Section(header: Text("Notificações")) {
                    Toggle(isOn: $enableNotifications) {
                        Text("Ativar Notificações")
                    }
                }
                
                Section(header: Text("Geral")) {
                    NavigationLink(destination: Text("Sobre o Aplicativo")) {
                        Text("Sobre o Aplicativo")
                    }
                    NavigationLink(destination: Text("Termos de Serviço")) {
                        Text("Termos de Serviço")
                    }
                }
                
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
            }
            .navigationTitle("Configurações")
        }
    }
}

#Preview {
    SettingsView()
}
