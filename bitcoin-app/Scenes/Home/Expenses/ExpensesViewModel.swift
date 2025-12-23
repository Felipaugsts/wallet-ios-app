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
    @Published var transactionsType: TransactionType
    @Published var isLoading: Bool
    @Published var showingAddSubscription: Bool
    @Published var datasource: [ExpenseModel] { didSet { filteredDatasource = datasource} }
    @Published var filteredDatasource: [ExpenseModel] = []
    @Published var editValue: ExpenseModel?
    @Published var loading: Bool
    @Published var showAlert: Bool
    @Published var selectedItemToDelete: ExpenseModel?
    @Published var selectedCategory: String = "" { didSet { handleFilter() } }
    
    var currentDate: Date?
    
    weak var delegate: DashboardDelegate?
    
    func handleFilter() {
        guard !selectedCategory.isEmpty else {
            filteredDatasource = datasource
            return
        }
        
        filteredDatasource = datasource.filter { item in
            item.selectedCategoryId == selectedCategory
        }
    }
    
    init(transactionsType: TransactionType,
         isLoading: Bool = true,
         showingAddSubscription: Bool = false,
         datasource: [ExpenseModel],
         editValue: ExpenseModel? = nil,
         loading: Bool,
         showAlert: Bool = false) {
        self.transactionsType = transactionsType
        self.isLoading = isLoading
        self.showingAddSubscription = showingAddSubscription
        self.datasource = datasource
        self.editValue = editValue
        self.loading = loading
        self.showAlert = showAlert
        
        self.selectedCategory = ""
    }
    
    lazy var categories: [Category] = {
        let allCategories: [Category] = RemoteConfigManager.shared.model(model: [Category].self, for: .wpCategories) ?? []
        
        return allCategories.filter { item in
            datasource.contains(where: { $0.selectedCategoryId == item.id })
        }
    }()
    
    func handleDeleteAction(item: ExpenseModel) {
        if item.isRecurring {
            showAlert = true
            selectedItemToDelete = item
            return
        }
        
        deleteTransaction(id: item.id)
    }
    
    func excludeFromCurrentMonth(id: String) {
        guard let currentDate else { return }
        if var transaction: ExpenseModel = datasource.first(where: { $0.id == id }) {
            
            if var dates = transaction.excludedMonths {
                dates.append(currentDate)
                transaction.excludedMonths = dates
            } else {
                transaction.excludedMonths = [currentDate]
            }
            
            let payload = transaction.toDict()
            HomeService().updateDocument(collection: .recurring,
                                         documentId: transaction.transactionID,
                                         updates: payload) { _ in
                withAnimation {
                    self.datasource.removeAll(where: { $0.id == id })
                }
            }
        }
    }
    
    func deleteTransaction(id: String, collection: String? = nil) {
        var collectionValue: Collections = .expenses
        
        if collection == nil {
            collectionValue = transactionsType == .expense ? .expenses : .incomes
        } else {
            collectionValue = .recurring
        }
        
        HomeService().deleteDocument(collection: collectionValue , documentId: id) { result in
            switch result {
            case .success(_):
                self.delegate?.updateTransactions = true
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
        delegate?.updateTransactions = true
    }
}

extension ExpensesViewModel: @preconcurrency TransactionDelegate {
    @MainActor
    func updateTransactions(transaction: ExpenseModel) {
        withAnimation(.spring) {
            if let firstDate = datasource.first?.dueDate, !isSameMonthAndYear(transaction.dueDate, firstDate) {
                _ = removeItem(transaction: transaction)
                return
            }
            
            if !transaction.transactionID.isEmpty, let index = datasource.firstIndex(where: { $0.transactionID == transaction.transactionID }) {
                datasource[index] = transaction
            } else {
                datasource.append(transaction)
            }
            
            handleFilter()
        }
        
        delegate?.updateTransactions = true
    }
    
    func removeItem(transaction: ExpenseModel) -> Bool {
        if let index = datasource.firstIndex(where: { $0.id == transaction.id }) {
            datasource.remove(at: index)
            return true
        }
        return false
    }
    
    private func isSameMonthAndYear(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        let month1 = calendar.component(.month, from: date1)
        let year1 = calendar.component(.year, from: date1)
        let month2 = calendar.component(.month, from: date2)
        let year2 = calendar.component(.year, from: date2)
        
        return month1 == month2 && year1 == year2
    }
}

struct Category: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let icon: String
    let isExpense: Bool
}
