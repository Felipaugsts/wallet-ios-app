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
    @Published var transactionType: TransactionType
    @Published var isRecurring: Bool = false
    @Published var recurrenceMonths: Int = 0
    @Published var shouldRemind: Bool = false
    @Published var value: Double = 0
    @Published var reminderDays: Int = 3
    @Published var shouldUpdateTransactions: Bool = false
    @Published var transaction: ExpenseModel = ExpenseModel(transactionID: "", dueDate: Date())
    @Published var isLoading: Bool = false
    
    init(transactionType: TransactionType) {
        self.transactionType = transactionType
    }
    
    // MARK: - Computed Properties
    var currencyColor: Color {
        transactionType == .expense ? .red : .green
    }
    
    var isFormValid: Bool {
        !transaction.name.isEmpty && Double(transaction.valueBRL) ?? 0 > 0 && !transaction.selectedCategoryId.isEmpty
    }
    
    // MARK: - Data Source
    lazy var expenseCategories: [Category] = {
        RemoteConfigManager.shared.model(model: [Category].self, for: .wpCategories) ?? [].filter { $0.isExpense == true }
    }()
    
    lazy var categories: [Category] = {
        let allCategories: [Category] = RemoteConfigManager.shared.model(model: [Category].self, for: .wpCategories) ?? []
        
        return allCategories.filter { $0.isExpense == (transactionType == .expense) }
    }()
    
    // MARK: - Actions
    
    func populateTransaction(transaction: ExpenseModel?) {
        guard let transaction else { return }
        
        self.transaction = transaction
        isRecurring = transaction.isRecurring
        transactionType = transaction.type
        
    }
    
    @MainActor
    func saveTransaction() {
        guard isFormValid else { return }
        isLoading = true
        
        let calendar = Calendar.current
        let month = calendar.component(.month, from: transaction.dueDate)
        let year = calendar.component(.year, from: transaction.dueDate)
        
        let data: [String: Any] = [
            "type": transactionType.rawValue,
            "name": transaction.name,
            "description": transaction.description,
            "categoryId": transaction.selectedCategoryId,
            "date": transaction.dueDate,
            "amount": transaction.valueBRL,
            "isRecurring": isRecurring,
            "recurrenceMonths": recurrenceMonths,
            "month": month,
            "icon": categories.first(where: { $0.id == transaction.selectedCategoryId })?.icon ?? "",
            "year": year
        ]
        
        if !transaction.transactionID.isEmpty, !isRecurring {
            updateExpense(data: data)
            return
        }
        
        if isRecurring {
            FirestoreUserService().createRecuringTransaction(data: data) { results in
                switch results {
                case .success(_):
                    self.shouldUpdateTransactions = true
                    
                case .failure(let failure):
                    print("failure", failure)
                }
            }
            
            return
        }
        
        saveTransaction(data: data, type: transactionType)
    }
 
    func updateExpense(data: [String: Any]) {
        let collection = transactionType == .expense ? "expenses" : "incomes"
        FirestoreUserService().updateDocument(collection: collection,
                                              documentId: transaction.transactionID,
                                              updates: data) { results in
            switch results {
            case .success(_):
                self.shouldUpdateTransactions = true
                
            case .failure(let error):
                print("updateExpense error:", error)
            }
        }
    }
    
    @MainActor
    func saveTransaction(data: [String: Any], type: TransactionType) {
        FirestoreUserService().createTransaction(data: data, type: type) { results in
            switch results {
            case .success(let id):
                if !id.isEmpty {
                    self.transaction.updateId(id)
                }
                self.shouldUpdateTransactions = true
                
            case .failure(let error):
                print("saveTransaction error:", error)
            }
        }
    }
}

enum TransactionType: String, CaseIterable, Codable {
    case expense = "Gasto"
    case income = "Receita"
}

// O objeto final que será salvo
struct TransactionTypeModel: Codable {
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
