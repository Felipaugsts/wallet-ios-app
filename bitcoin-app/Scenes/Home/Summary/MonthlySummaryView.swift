//
//  MonthlySummaryView.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 12/10/25.
//

import SwiftUI

// MARK: - Monthly Summary
struct MonthlySummaryView: View {
    let income: Double
    let expenses: Double
    
    var savings: Double {
        income - expenses
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                SummaryItemView(title: "Receitas", amount: income, color: .green)
                SummaryItemView(title: "Despesas", amount: expenses, color: .red)
            }
            
            Divider()
            
            HStack {
                Text("Economia do Mês")
                    .font(.headline)
                Spacer()
                Text("R$ \(savings, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(savings >= 0 ? .green : .red)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview(body: {
    MonthlySummaryView(income: 2000, expenses: 3000)
})

struct SummaryItemView: View {
    let title: String
    let amount: Double
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: "arrow.up.forward.square.fill")
                .font(.title)
                .foregroundColor(.white)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white)
                Text("R$ \(amount, specifier: "%.2f")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(color)
        .cornerRadius(16)
    }
}

