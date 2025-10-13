//
//  TransactionDetailRowView.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 12/10/25.
//

import SwiftUI

enum TransactionFilter {
    case all, income, expense
}

struct TransactionDetailRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 12) {
            // Ícone da categoria
            Circle()
                .fill(categoryColor.opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: categoryIcon)
                        .foregroundColor(categoryColor)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.body)
                    .fontWeight(.medium)
                Text(transaction.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(transaction.amount >= 0 ? "+" : "")R$ \(abs(transaction.amount), specifier: "%.2f")")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(transaction.amount >= 0 ? .green : .red)
        }
        .padding(.vertical, 4)
    }
    
    var categoryColor: Color {
        switch transaction.category {
        case "Alimentação": return .orange
        case "Transporte": return .blue
        case "Moradia": return .purple
        case "Lazer": return .pink
        case "Saúde": return .green
        case "Receita": return .green
        default: return .gray
        }
    }
    
    var categoryIcon: String {
        switch transaction.category {
        case "Alimentação": return "cart.fill"
        case "Transporte": return "car.fill"
        case "Moradia": return "house.fill"
        case "Lazer": return "gamecontroller.fill"
        case "Saúde": return "heart.fill"
        case "Receita": return "arrow.down.circle.fill"
        default: return "tag.fill"
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("Nenhuma transação encontrada")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Adicione sua primeira transação para começar")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Row View

struct TransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 12) {
            // Ícone da categoria
            Circle()
                .fill(transaction.amount >= 0 ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: transaction.amount >= 0 ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                        .foregroundColor(transaction.amount >= 0 ? .green : .red)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(transaction.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(transaction.amount >= 0 ? "+" : "")R$ \(abs(transaction.amount), specifier: "%.2f")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(transaction.amount >= 0 ? .green : .red)
                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}
