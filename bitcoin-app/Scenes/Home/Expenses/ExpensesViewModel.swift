//
//  ExpensesViewModel.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 14/12/25.
//

//TransactionDelegate

import Foundation
import SwiftUI

class ExpensesViewModel: ObservableObject {
    @Published var transactionsType: TransactionType = .expense
    @Published var isLoading = true
    @Published var tabItems: [TabItem] = []
    @Published var showingAddSubscription = false
    @Published var datasource: [ExpenseModel] = []
    @Published var editValue: ExpenseModel?
    @Published var loading: Bool = true
    
    lazy var categories: [Category] = {
           let allCategories: [Category] = RemoteConfigManager.shared.model(model: [Category].self, for: .wpCategories) ?? []
           
           return allCategories.filter { $0.isExpense == (transactionsType != .expense) }
       }()
    
    func deleteTransaction(id: String) {
        let collection = transactionsType == .expense ? "expenses" : "incomes"
        
        FirestoreUserService().deleteDocument(collection: collection, documentId: id) { result in
            switch result {
            case .success(_):
                withAnimation {
                    self.datasource.removeAll(where: { $0.id == id })
                }
                
            case .failure(_):
                break
            }
        }
    }
    
    func editTransaction(value: ExpenseModel) {
        editValue = value
        showingAddSubscription = true
    }
}

extension ExpensesViewModel: TransactionDelegate {
    func updateTransactions(transaction: ExpenseModel) {
        withAnimation(.spring) {
            if let index = datasource.firstIndex(where: { $0.id == transaction.id }) {
                datasource[index] = transaction
            } else {
                datasource.append(transaction)
            }
        }
    }
}

struct Category: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let icon: String
    let isExpense: Bool
}
