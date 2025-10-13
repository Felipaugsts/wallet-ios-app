//
//  GoalsView.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 12/10/25.
//

import SwiftUI

struct GoalsView: View {
    @State private var goals: [FinancialGoal] = [
        FinancialGoal(title: "Viagem para Europa", targetAmount: 15000, currentAmount: 8500, deadline: Date().addingTimeInterval(180 * 86400), icon: "airplane", color: .blue),
        FinancialGoal(title: "Fundo de Emergência", targetAmount: 30000, currentAmount: 12000, deadline: Date().addingTimeInterval(365 * 86400), icon: "shield.fill", color: .green),
        FinancialGoal(title: "Novo MacBook", targetAmount: 12000, currentAmount: 5400, deadline: Date().addingTimeInterval(120 * 86400), icon: "laptopcomputer", color: .purple),
        FinancialGoal(title: "Curso de Investimentos", targetAmount: 2500, currentAmount: 2100, deadline: Date().addingTimeInterval(60 * 86400), icon: "book.fill", color: .orange)
    ]
    
    @State private var showingAddGoal = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Resumo de Metas
                    GoalsSummaryView(goals: goals)
                        .padding(.horizontal)
                    
                    // Lista de Metas
                    VStack(spacing: 16) {
                        ForEach(goals) { goal in
                            GoalCardView(goal: goal)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                .padding(.top)
            }
            .navigationTitle("Metas")
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddGoal = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView()
            }
        }
    }
}

struct FinancialGoal: Identifiable {
    let id = UUID()
    let title: String
    let targetAmount: Double
    var currentAmount: Double
    let deadline: Date
    let icon: String
    let color: Color
    
    var remaining: Double {
        targetAmount - currentAmount
    }
    
    var percentageAchieved: Double {
        (currentAmount / targetAmount) * 100
    }
    
    var isCompleted: Bool {
        currentAmount >= targetAmount
    }
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: deadline)
        return components.day ?? 0
    }
}

