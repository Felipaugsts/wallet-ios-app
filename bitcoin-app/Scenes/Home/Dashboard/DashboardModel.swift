//
//  DashboardModel.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 13/12/25.
//

import SwiftUI

struct CreditCard: Identifiable, Hashable {
    let id = UUID(); let name: String; var available: Double; var spent: Double; let dueDate: Date; var isPaid: Bool
}

struct TransactionModel: Identifiable, Hashable {
    let id = UUID(); let date: Date; let category: String; let value: Double
    var iconName: String {
        switch category {
        case "Salário": return "dollarsign.circle.fill"; case "Investimento": return "chart.line.uptrend.circle.fill"; case "Aluguel": return "house.fill"; case "Supermercado": return "cart.fill"; case "Restaurante": return "fork.knife.circle.fill"; case "Presentes": return "gift.fill"; case "Serviços": return "wrench.and.screwdriver.fill"; case "Café": return "cup.and.saucer.fill"; case "Transporte": return "car.fill"; default: return "tag.fill"
        }
    }
}

struct FinancialData {
    var expenses: Double; var incomes: Double; var invested: Double; var dividends: Double; var creditCards: [CreditCard]; var transactions: [TransactionModel]
}
