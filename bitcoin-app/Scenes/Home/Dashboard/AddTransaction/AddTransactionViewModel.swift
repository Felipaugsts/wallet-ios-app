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
    @Published var isRecurring: Bool = false
    @Published var recurrenceMonths: Int = 2
    @Published var shouldRemind: Bool = false
    @Published var value: Double = 0
    @Published var reminderDays: Int = 3
    @Published var shouldUpdateTransactions: Bool = false
    @Published var transaction: ExpenseModel = ExpenseModel(transactionID: "")
    @Published var isLoading: Bool = false
    
    // MARK: - Computed Properties
    var currencyColor: Color {
        transactionType == .expense ? .red : .green
    }
    
    var isFormValid: Bool {
        !transaction.name.isEmpty && Double(transaction.valueBRL) ?? 0 > 0 && !transaction.selectedCategoryId.isEmpty
    }
    
    // MARK: - Data Source
    let expenseCategories: [Category] = {
        RemoteConfigManager.shared.model(model: [Category].self, for: .wpCategories) ?? [].filter { $0.isExpense == true }
    }()
    
    lazy var categories: [Category] = {
        let allCategories: [Category] = RemoteConfigManager.shared.model(model: [Category].self, for: .wpCategories) ?? []
        
        return allCategories.filter { $0.isExpense == (transactionType != .expense) }
    }()
    
    // MARK: - Actions
    
    func populateTransaction(transaction: ExpenseModel?) {
        guard let transaction else { return }
        
        self.transaction = transaction
        transactionType = transaction.type
        
    }
    
    func saveTransaction() {
        guard isFormValid else { return }
        isLoading = true

        let calendar = Calendar.current
        let month = calendar.component(.month, from: transaction.dueDate)
        let year = calendar.component(.year, from: transaction.dueDate)
        
        let data: [String: Any] = [
            "user_id": "FJN3yYhhiRYJZlWHefhaCV9L2xE3",
            "type": transactionType.rawValue,
            "name": transaction.name,
            "description": transaction.description,
            "categoryId": transaction.selectedCategoryId,
            "date": transaction.dueDate,
            "amount": transaction.valueBRL,
            "isRecurring": isRecurring,
            "recurrenceMonths": recurrenceMonths,
            "month": month,
            "icon": categories.first(where: { $0.name == transaction.selectedCategoryId }) ?? "",
            "year": year
        ]
        if !transaction.transactionID.isEmpty{
            updateExpense(data: data)
            return
        }
        
        if transactionType == .expense {
            saveExpense(data: data)
            return
        }
        
        if transactionType == .income {
            saveIncome(data: data)
            return
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
    
    func updateExpense(data: [String: Any]) {
        let collection = transactionType == .expense ? "expenses" : "incomes"
        FirestoreUserService().updateDocument(collection: collection,
                                              documentId: transaction.id,
                                              updates: data) { results in
            switch results {
            case .success(_):
                self.shouldUpdateTransactions = true
            case .failure(_):
                break
            }
        }
    }
    
    func saveExpense(data: [String: Any]) {
        FirestoreUserService().createExpense(data: data) { results in
            switch results {
            case .success( _):
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

// O objeto final que será salvo
struct TransactionTypeModel {
    let transactionId: String
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
    func updateTransactions(transaction: ExpenseModel)
}
