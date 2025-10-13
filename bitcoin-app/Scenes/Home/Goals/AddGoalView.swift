//
//  AddGoalView.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 12/10/25.
//

import SwiftUI

// MARK: - Add Goal View (Placeholder)
struct AddGoalView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Detalhes da Meta")) {
                    TextField("Título da Meta", text: .constant(""))
                    TextField("Valor Alvo", text: .constant(""))
                        .keyboardType(.decimalPad)
                    TextField("Valor Atual", text: .constant(""))
                        .keyboardType(.decimalPad)
                    DatePicker("Prazo", selection: .constant(Date()), displayedComponents: .date)
                }
                
                Section(header: Text("Personalização")) {
                    Picker("Ícone", selection: .constant(0)) {
                        Text("✈️ Viagem").tag(0)
                        Text("🛡️ Emergência").tag(1)
                        Text("💻 Eletrônicos").tag(2)
                        Text("📚 Educação").tag(3)
                    }
                }
            }
            .navigationTitle("Nova Meta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        dismiss()
                    }
                }
            }
        }
    }
}
