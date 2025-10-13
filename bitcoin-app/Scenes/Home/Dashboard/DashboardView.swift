//
//  DashboardView.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 12/10/25.
//

import SwiftUI

struct DashboardView: View {
    @State private var totalBalance: Double = 15430.50
    @State private var monthlyIncome: Double = 8500.00
    @State private var monthlyExpenses: Double = 5234.75
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 15) {
                    VStack {
                        ProfileView()
                        
//                        HStack {
//                            Image(systemName: "chevron.left")
//                                .foregroundColor(.black)
//                                .font(.caption)
//                            Spacer()
//                            Text("Outubro")
//                                .font(.headline)
//                            Spacer()
//                            Image(systemName: "chevron.right")
//                                .foregroundColor(.black)
//                                .font(.caption)
//                        }
                    }
                    
                    // Saldo Total Card
//                    BalanceCardView(balance: totalBalance)
                    
                    // Resumo Mensal
                    MonthlySummaryView(income: monthlyIncome, expenses: monthlyExpenses)
                    
                    // Gráfico de Gastos por Categoria
                    ExpensesByCategoryChartView()
                    
                    // Transações Recentes
                    RecentTransactionsView()
                    // Botão de Ação Rápida
                    QuickActionButton()
                        .padding(.bottom, 20)
                }
                .padding(.top)
            }
            .padding(.horizontal)
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct ProfileView: View {
    var body: some View {
        Section {
            HStack(spacing: 16) {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text("JD")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Felipe Augusto")
                        .font(.headline)
                        .foregroundColor(.black.opacity(0.6))
                    
                    Text("Welcome back!")
                        .font(.caption)
                        .foregroundColor(.black.opacity(0.6))
                }
                
                Spacer()
                
                VStack {
                    Image(systemName: "bell")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
            }
            .padding(.vertical, 8)
        }
    }
}

#Preview(body: {
    DashboardView()
})
