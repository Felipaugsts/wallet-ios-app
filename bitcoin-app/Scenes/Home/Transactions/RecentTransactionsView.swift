//
//  RecentTransactionsView.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 12/10/25.
//

import SwiftUI

// MARK: - Recent Transactions
struct RecentTransactionsView: View {
    let transactions: [Transaction] = [
        Transaction(title: "Supermercado", category: "Alimentação", amount: -234.50, date: Date()),
        Transaction(title: "Salário", category: "Receita", amount: 8500.00, date: Date().addingTimeInterval(-86400)),
        Transaction(title: "Uber", category: "Transporte", amount: -45.30, date: Date().addingTimeInterval(-172800)),
        Transaction(title: "Netflix", category: "Lazer", amount: -39.90, date: Date().addingTimeInterval(-259200))
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Transações Recentes")
                    .font(.headline)
                Spacer()
                Button(action: {}) {
                    Text("Ver Todas")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            VStack(spacing: 0) {
                ForEach(transactions) { transaction in
                    TransactionRowView(transaction: transaction)
                    if transaction.id != transactions.last?.id {
                        Divider()
                            .padding(.leading, 60)
                    }
                }
            }
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

