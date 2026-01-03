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
    @Published var shouldUpdateTransactions: Bool = false
    @Published var transaction: ExpenseModel = ExpenseModel(transactionID: "", dueDate: Date(), recurring: RecurringConfig(isRecurring: false))
    @Published var isLoading: Bool = false
    @Published var currentSelectedDate: Date = Date()
    
    var homeService: HomeService
    weak var delegate: TransactionDelegate?
    
    init(transactionType: TransactionType,
         homeService: HomeService = HomeService(),
         delegate: TransactionDelegate?) {
        self.transactionType = transactionType
        self.homeService = homeService
        self.delegate = delegate
    }
    
    // MARK: - Computed Properties
    
    var isRecurringEnabled: Bool = {
        RemoteConfigManager().bool(for: .recurringEnabled)
    }()
    
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
    var changedToRecurring: Bool = false
    
    @MainActor
    func saveTransaction() {
        guard isFormValid else { return }
        isLoading = true
        
        let calendar = Calendar.current
        let month = calendar.component(.month, from: currentSelectedDate)
        let year = calendar.component(.year, from: currentSelectedDate)
        if !transaction.isRecurring && isRecurring {
            changedToRecurring = true
        }
        
        transaction.type = transactionType
        transaction.dueDate = currentSelectedDate
        transaction.isRecurring = isRecurring
        transaction.recurring.isRecurring = isRecurring
        transaction.icon = categories.first(where: { $0.id == transaction.selectedCategoryId })?.icon ?? ""
        transaction.year = year
        transaction.month = month

        if !transaction.transactionID.isEmpty && !isRecurring {
            updateExpense(data: transaction)
            shouldUpdateTransactions = true
            return
        } else if changedToRecurring && !transaction.transactionID.isEmpty {
            transaction.recurring.isRecurring = true
            transaction.isRecurring = false
            homeService.createTransactionWithDocumentId(collection: .recurring,
                                                        id: transaction.transactionID,
                                                        data: transaction)
            
            shouldUpdateTransactions = true
            delegate?.updateTransactions(transaction: transaction)
            return
        } else if isRecurring && !transaction.transactionID.isEmpty {
            homeService.createTransactionWithDocumentId(collection: transaction.type == .expense ? .expenses : .incomes,
                                                        id: transaction.transactionID,
                                                        data: transaction)
            
            shouldUpdateTransactions = true
            delegate?.addTransactions(transaction: transaction)
            return
        }
        
        
        if isRecurring && transaction.recurringEditable ?? true {
            homeService.createTransaction(data: transaction, collection: .recurring) { results in
                switch results {
                case .success(let id):
                    self.shouldUpdateTransactions = true
                    self.transaction.updateId(id)
                    self.delegate?.addTransactions(transaction: self.transaction)
                    
                case .failure(let failure):
                    print("failure", failure)
                }
            }
            
            return
        }
        
        saveTransaction(data: transaction, type: transactionType)
    }
    
    func updateExpense(data: ExpenseModel) {
        let collection: Collections = transactionType == .expense ? .expenses : .incomes
        homeService.updateDocument(collection: collection, documentId: transaction.transactionID, updates: data) { results in
            switch results {
            case .success(_):
                self.shouldUpdateTransactions = true
                self.delegate?.updateTransactions(transaction: data)
                
            case .failure(let error):
                print("updateExpense error:", error)
            }
        }
    }
    
    @MainActor
    func saveTransaction(data: ExpenseModel, type: TransactionType) {
        homeService.createTransaction(data: data, collection: type == .expense ? .expenses : .incomes) { results in
            switch results {
            case .success(let id):
                if !id.isEmpty {
                    self.transaction.updateId(id)
                }
                self.delegate?.addTransactions(transaction: self.transaction)
                
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
    func deleteTransactions(transaction: ExpenseModel)
    func addTransactions(transaction: ExpenseModel)
}
