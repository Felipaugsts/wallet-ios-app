//
//  HomeService.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 13/12/25.
//

import Foundation
import SwiftUICore
import Firebase

final class HomeService {
    
    // MARK: - Properties
    
    let userId = UserRepository.shared.loadUser()?.id ?? ""
    var expensesTransactions: [ExpenseModel] = [] {
        didSet {
            print("expensesTransactions123", expensesTransactions)
        }
    }
    var incomeTransactions: [ExpenseModel] = []
    var recuringTransactions: [ExpenseModel] = []
    var date: Date = Date()
    
    var service: DatabaseServiceProtocol
    
    init(service: DatabaseServiceProtocol = FirestoreService.shared) {
        self.service = service
    }
    
    // MARK: - User Overview
    
    func getUserOverview(month: Int, year: Int) async throws -> OverviewResult {
        guard let date = getDateFrom(month: month, year: year) else { throw NSError(domain: "InvalidDateError", code: 0, userInfo: nil) }
        self.date = date
        
        try await handleRecurringTransactions()
        
        let incomeCurrent = try await getTotal(collection: .incomes, month: month, year: year, currentTransactions: &incomeTransactions)
        let expenseCurrent = try await getTotal(collection: .expenses, month: month, year: year, currentTransactions: &expensesTransactions)
        
        let balanceCurrent = incomeCurrent - expenseCurrent
        
        return OverviewResult(
            incomeTotal: incomeCurrent,
            expenseTotal: expenseCurrent,
            balance: balanceCurrent,
            incomeChangePercent: 0,
            expenseChangePercent: 0,
            balanceChangePercent: 0,
            totalInvestedValue: 0,
            currentMonthDividends: 0,
            expensesTransactions: expensesTransactions,
            incomeTransactions: incomeTransactions,
            recuringTransactions: recuringTransactions
        )
    }
    
    // MARK: - Create Expense
    
    func createTransaction(
        data: [String: Any],
        collection: Collections,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        var payload = data
        payload["created_at"] = Timestamp(date: Date())
        payload["updated_at"] = Timestamp(date: Date())
        payload["user_id"] = userId
        
        service.create(collection: collection, payload: payload, completion: completion)
    }
    
    func createTransactionWithDocumentId(collection: Collections, id: String, data: [String: Any]) {
        var payload = data
        
        payload["created_at"] = Timestamp(date: Date())
        payload["updated_at"] = Timestamp(date: Date())
        payload["user_id"] = userId
        
        service.create(withDocumentId: id, collection: collection, payload: payload) { _ in }
    }
    
    // MARK: - Fetch
    
    func fetchRecuringTransactions() async throws -> Transactions {
        var transactions = Transactions(expensesTransactions: [], incomeTransactions: [])
        
        do {
            let data = try await service.fetch(collection: .recurring, userId: userId)
            for (documentId, documentData) in data {
                if let documentData = documentData as? [String: Any],
                   let transaction = documentData.createExpenseModel(documentId: documentId) {
                    if transaction.type == .expense {
                        transactions.expensesTransactions.append(transaction)
                    } else {
                        transactions.incomeTransactions.append(transaction)
                    }
                }
            }
        } catch {
            throw error
        }
        
        return transactions
    }
    
    // MARK: - Update
    
    func updateDocument(collection: Collections, documentId: String, updates: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        var payload = updates
        payload["updated_at"] = Timestamp(date: Date())
        
        service.updateDocument(collection: collection, documentId: documentId, updates: payload, completion: completion)
    }
    
    // MARK: - Delete
    
    func deleteDocument(collection: Collections, documentId: String, completion: @escaping (Result<Void, Error>) -> Void ) {
        service.deleteDocument(collection: collection, documentId: documentId, completion: completion)
    }
    
    // MARK: - Private Methods
    
    func getDateFrom(month: Int, year: Int) -> Date? {
        let dateComponents = DateComponents(year: year, month: month, day: 30)
        guard let date = Calendar.current.date(from: dateComponents) else {
            return nil
        }
        
        return date
    }
    
    // MARK: - Recurring
    
    func handleRecurringTransactions() async throws -> Void {
        let transaction = try await fetchRecuringTransactions()
        
        let newExpenses = transaction.expensesTransactions.filter { newExpense in
            newExpense.recurringEditable ?? true && newExpense.dueDate < date && !expensesTransactions.contains(where: { $0.id == newExpense.id })
        }
        
        let newIncome = transaction.incomeTransactions.filter { newIncome in
            newIncome.recurringEditable ?? true && newIncome.dueDate < date && !incomeTransactions.contains(where: { $0.id == newIncome.id })
        }
        
        expensesTransactions.append(contentsOf: newExpenses)
        incomeTransactions.append(contentsOf: newIncome)
        recuringTransactions = transaction.expensesTransactions + transaction.incomeTransactions
    }
    
    func getTotal(collection: Collections, month: Int, year: Int, currentTransactions: inout [ExpenseModel]) async throws -> Double {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = 1
        let date = Calendar.current.date(from: dateComponents)
        
        let data = try await service.fetch(collection: collection, userId: userId)
        
        let transactions: [ExpenseModel] = data.compactMap { (documentId, documentData) in
            guard let documentData = documentData as? [String: Any],
                  let monthValue = documentData["month"] as? Int,
                  let yearValue = documentData["year"] as? Int,
                  monthValue == month,
                  yearValue == year else {
                return nil
            }
            
            return documentData.createExpenseModel(documentId: documentId)
        }.compactMap { $0 }
        
        validateTransaction(currentList: &currentTransactions, transactions: transactions, date: date)
        
        return self.totalAmount(for: currentTransactions)
    }
    
    func validateTransaction(currentList: inout [ExpenseModel], transactions: [ ExpenseModel], date: Date?) {
        if let date {
            currentList.removeAll(where: { item in
                if let excluded = item.excludedMonths {
                    return excluded.contains(where: { excludedDate in
                        excludedDate.isSameMonthAndYear(as: date)
                    })
                }
                return false
            })
        }
        
        transactions.forEach { expense in
            
            if let existingExpenseIndex = currentList.firstIndex(where: { $0.transactionID == expense.transactionID }) {
                
                if expense.recurringEditable == true {
                    self.createTransactionWithDocumentId(collection: .expenses, id: expense.transactionID, data: expense.toDict(recurringEditable: false))
                } else {
                    currentList.remove(at: existingExpenseIndex) // remove currency
                    currentList.append(expense) // and add value edited for this month
                }
            } else {
                currentList.append(expense)
            }
        }
    }
    
    func totalAmount(for transactions: [ExpenseModel]) -> Double {
        return transactions.reduce(0.0) { (result, val) in
            if let amountDouble = Double(val.valueBRL) {
                return result + amountDouble
            }
            return result
        }
    }
    
    func summarizeCreditCard(filter: String, title: String, income: Double?, data: [ExpenseModel]?) async throws -> ExpensesSummaryModel {
        guard let income, let data else {
            throw NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: ""])
        }
        
        let incomeInt = Int(income)
        
        let summaries: [SummaryItem] = data.compactMap { expense in
            guard expense.selectedCategoryId == filter, let amount = Double(expense.valueBRL) else { return nil }
            
            return SummaryItem(
                title: expense.name,
                subtitle: expense.description,
                amount: amount,
                percentageOfIncome: 0,
                status: .danger,
                icon: expense.icon,
                dueDate: expense.dueDate
            )
        }


        let totalExpenses = summaries.compactMap { Double($0.amount) }.reduce(0.0, +)
        
        let percentageOfIncome = (totalExpenses / Double(incomeInt)) * 100
        
        return ExpensesSummaryModel(title: title,
                                    totalAmount: 12,
                                    porcentageRalatedToIncome: formatPercentage(percentageOfIncome),
                                    status: .normal,
                                    items: summaries)
    }
    
    func formatPercentage(_ value: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.maximumIntegerDigits = 2
        
        if let formattedValue = numberFormatter.string(from: NSNumber(value: value)) {
            return formattedValue
        }
        
        return "0.00"
    }
}

struct ExpensesSummaryModel: Codable, Identifiable {
    var id: UUID = UUID()
    var title: String
    var totalAmount: Double
    var porcentageRalatedToIncome: String
    let status: SummaryStatus
    var items: [SummaryItem]
}

extension ExpensesSummaryModel {
    static var loadingStateValues = {
        ExpensesSummaryModel(title: "Loading",
                             totalAmount: 0,
                             porcentageRalatedToIncome: "0",
                             status: .normal,
                             items: [])
    }()
}

struct SummaryItem: Codable, Identifiable {
    var id: UUID = UUID()
    let title: String
    let subtitle: String?
    let amount: Double
    let percentageOfIncome: Double
    let status: SummaryStatus
    let icon: String
    var dueDate: Date
}
