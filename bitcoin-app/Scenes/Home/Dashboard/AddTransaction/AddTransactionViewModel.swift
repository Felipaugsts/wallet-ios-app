//
//  AddTransactionViewModel.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 13/12/25.
//

import Combine
import SwiftUI

@MainActor
class AddTransactionViewModel: ObservableObject {
    
    // MARK: - Form State
    @Published var transactionType: TransactionType = .expense
    @Published var amount: Double = 0.0
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var date: Date = Date()
    @Published var selectedCategoryId: String = ""
    @Published var isRecurring: Bool = false
    @Published var recurrenceMonths: Int = 2
    @Published var shouldRemind: Bool = false
    @Published var reminderDays: Int = 3
    @Published var shouldUpdateTransactions: Bool = false
    
    // MARK: - Computed Properties
    var currencyColor: Color {
        transactionType == .expense ? .red : .green
    }
    
    var isFormValid: Bool {
        !name.isEmpty && amount > 0 && !selectedCategoryId.isEmpty
    }
    
    var categories: [Category] {
        transactionType == .expense ? expenseCategories : incomeCategories
    }
    
    // MARK: - Data Source
    let expenseCategories: [Category] = [
        .init(id: "fixed", name: "Contas Fixas", icon: "house.fill"),
        .init(id: "credit_card", name: "Cartão de Crédito", icon: "creditcard.fill"),
        .init(id: "transport", name: "Transporte", icon: "car.fill"),
        .init(id: "food", name: "Alimentação", icon: "fork.knife"),
        .init(id: "leisure", name: "Lazer", icon: "popcorn.fill"),
        .init(id: "other", name: "Outros", icon: "tag.fill")
    ]
    
    let incomeCategories: [Category] = [
        .init(id: "salary", name: "Salário", icon: "dollarsign.circle.fill"),
        .init(id: "dividends", name: "Dividendos", icon: "chart.line.uptrend.xyaxis.circle.fill"),
        .init(id: "freelance", name: "Freelance", icon: "laptopcomputer"),
        .init(id: "other", name: "Outros", icon: "tag.fill")
    ]
    
    // MARK: - Actions
    func saveTransaction() {
        guard isFormValid else { return }
        let data: [String: Any] = [
            "user_id": "FJN3yYhhiRYJZlWHefhaCV9L2xE3",
            "type": transactionType.rawValue,
            "name": name,
            "description": description,
            "categoryId": selectedCategoryId,
            "date": date,
            "amount": amount,
            "isRecurring": isRecurring,
            "recurrenceMonths": recurrenceMonths,
            "month": 12,
            "year": 2025
        ]
        
        if transactionType == .expense {
            saveExpense(data: data)
        } else if transactionType == .income {
            saveIncome(data: data)
        }
    }
    
    func saveIncome(data: [String: Any]) {
        FirestoreUserService().createIncome(data: data) { results in
            switch results {
            case .success(let success):
                print("success", success)
                self.shouldUpdateTransactions = true
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    func saveExpense(data: [String: Any]) {
        FirestoreUserService().createExpense(data: data) { results in
            switch results {
            case .success(let success):
                print("success")
                self.shouldUpdateTransactions = true
            case .failure(let failure):
                print(failure)
            }
        }
    }
}

enum TransactionType: String, CaseIterable {
    case expense = "Gasto"
    case income = "Receita"
}

// Struct para representar uma categoria
struct Category: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String
}

// O objeto final que será salvo
struct TransactionTypeModel {
    let type: TransactionType
    let name: String
    let description: String
    let amount: Double
    let categoryId: String
    let date: Date
    let isRecurring: Bool
    let recurrenceMonths: Int
}

protocol TransactionDelegate: AnyObject {
    func updateTransactions()
}
