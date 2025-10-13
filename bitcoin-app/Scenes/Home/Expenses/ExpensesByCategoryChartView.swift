//
//  ExpensesByCategoryChartView.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 12/10/25.
//

import SwiftUI
import Charts

// MARK: - Expenses by Category Chart
struct ExpensesByCategoryChartView: View {
    let expenseData: [ExpenseCategory] = [
        ExpenseCategory(name: "Alimentação", amount: 1500, color: .orange),
        ExpenseCategory(name: "Transporte", amount: 800, color: .blue),
        ExpenseCategory(name: "Moradia", amount: 2000, color: .purple),
        ExpenseCategory(name: "Lazer", amount: 600, color: .pink),
        ExpenseCategory(name: "Saúde", amount: 334.75, color: .green)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Gastos por Categoria")
                .font(.headline)
                .padding(.horizontal)
            
            // Gráfico de Pizza
            Chart(expenseData) { category in
                SectorMark(
                    angle: .value("Valor", category.amount),
                    innerRadius: .ratio(0.5),
                    angularInset: 1.5
                )
                .foregroundStyle(category.color)
                .cornerRadius(5)
            }
            .frame(height: 250)
            .padding()
            
            // Legenda
            VStack(spacing: 8) {
                ForEach(expenseData) { category in
                    HStack {
                        Circle()
                            .fill(category.color)
                            .frame(width: 12, height: 12)
                        Text(category.name)
                            .font(.subheadline)
                        Spacer()
                        Text("R$ \(category.amount, specifier: "%.2f")")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct ExpenseCategory: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let color: Color
}

