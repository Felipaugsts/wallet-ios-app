//
//  GoalCardView.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 12/10/25.
//

import SwiftUI

// MARK: - Goals Summary
struct GoalsSummaryView: View {
    let goals: [FinancialGoal]
    
    var totalTarget: Double {
        goals.reduce(0) { $0 + $1.targetAmount }
    }
    
    var totalSaved: Double {
        goals.reduce(0) { $0 + $1.currentAmount }
    }
    
    var completedGoals: Int {
        goals.filter { $0.isCompleted }.count
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total de Metas")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("\(goals.count)")
                        .font(.system(size: 28, weight: .bold))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text("Concluídas")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("\(completedGoals)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.green)
                }
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Economizado")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("R$ \(totalSaved, specifier: "%.2f")")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Meta Total")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("R$ \(totalTarget, specifier: "%.2f")")
                        .font(.headline)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}


// MARK: - Goal Card
struct GoalCardView: View {
    let goal: FinancialGoal
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                // Ícone e Título
                HStack(spacing: 12) {
                    Circle()
                        .fill(goal.color.opacity(0.2))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: goal.icon)
                                .font(.title3)
                                .foregroundColor(goal.color)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(goal.title)
                            .font(.headline)
                        Text("Meta: R$ \(goal.targetAmount, specifier: "%.2f")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Status
                if goal.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }
            }
            
            // Barra de Progresso
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progresso: \(min(goal.percentageAchieved, 100), specifier: "%.1f")%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("R$ \(goal.currentAmount, specifier: "%.2f")")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 10)
                        
                        // Progress
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [goal.color, goal.color.opacity(0.7)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: min(CGFloat(goal.percentageAchieved / 100) * geometry.size.width, geometry.size.width), height: 10)
                            .animation(.easeInOut, value: goal.percentageAchieved)
                    }
                }
                .frame(height: 10)
            }
            
            // Informações Adicionais
            HStack {
                // Faltam
                VStack(alignment: .leading, spacing: 4) {
                    Text("Faltam")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("R$ \(max(goal.remaining, 0), specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                // Prazo
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Prazo")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text("\(goal.daysRemaining) dias")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(goal.daysRemaining < 30 ? .orange : .primary)
                }
            }
            
            // Botão de Ação
            if !goal.isCompleted {
                Button(action: {
                    // Ação para adicionar valor à meta
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Adicionar Valor")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(goal.color.opacity(0.1))
                    .foregroundColor(goal.color)
                    .cornerRadius(8)
                }
            } else {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Meta Atingida!")
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
