//
//  AddTransactionView.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 12/10/25.
//

import SwiftUI

struct Transaction: Identifiable {
    let id = UUID()
    let title: String
    let category: String
    let amount: Double
    let date: Date
}


// MARK: - Quick Action Button
struct QuickActionButton: View {
    @State private var showingAddTransaction = false
    
    var body: some View {
        Button(action: {
            showingAddTransaction = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                Text("Adicionar Transação")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView()
        }
    }
}


// MARK: - Add Transaction View (Placeholder)
struct AddTransactionView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Detalhes da Transação")) {
                    TextField("Descrição", text: .constant(""))
                    TextField("Valor", text: .constant(""))
                    Picker("Categoria", selection: .constant(0)) {
                        Text("Alimentação").tag(0)
                        Text("Transporte").tag(1)
                        Text("Moradia").tag(2)
                    }
                    DatePicker("Data", selection: .constant(Date()), displayedComponents: .date)
                }
            }
            .navigationTitle("Nova Transação")
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

