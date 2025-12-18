//
//  DashboardService.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 13/12/25.
//

import Foundation
import FirebaseFirestore
import SwiftUICore

struct LoadedOverview {
    var overview: OverviewResult
    var date: Date
}

struct OverviewResult {
    let incomeTotal: Double
    let expenseTotal: Double
    let balance: Double
    
    let incomeChangePercent: Double
    let expenseChangePercent: Double
    let balanceChangePercent: Double
    
    let totalInvestedValue: Double
    let currentMonthDividends: Double
    
    var expensesTransactions: [ExpenseModel]
    var incomeTransactions: [ExpenseModel]
    var recuringTransactions: [ExpenseModel]
}

struct Transactions {
    var expensesTransactions: [ExpenseModel]
    var incomeTransactions: [ExpenseModel]
}

final class FirestoreUserService {
    
    // MARK: - Properties
    
    private let db = Firestore.firestore()
    
    // MARK: - User Overview (Month)
    
    func getUserOverview(
        month: Int,
        year: Int
    ) async throws -> OverviewResult {
        let userId = UserRepository.shared.loadUser()?.id ?? ""
        
        var expensesTransactions: [ExpenseModel] = []
        var incomeTransactions: [ExpenseModel] = []
        var recuringTransactions: [ExpenseModel] = []
        
        func getTotal(collection: String, month: Int, year: Int) async throws -> Double {
            let snap = try await db.collection(collection)
                .whereField("user_id", isEqualTo: userId)
                .whereField("month", isEqualTo: month)
                .whereField("year", isEqualTo: year)
                .getDocuments()
            
            let transactions = snap.documents.compactMap { document -> ExpenseModel? in
                let data = document.data()
                return self.createExpenseModel(from: data, documentId: document.documentID)
            }
            
            if collection == "expenses" {
                expensesTransactions.append(contentsOf: transactions)
                return self.totalAmount(for: expensesTransactions)
            }
            
            incomeTransactions.append(contentsOf: transactions)
            
            return self.totalAmount(for: incomeTransactions)
        }
        
        // Fetch recurring transactions first
        let transaction = try await fetchRecuringTransactions()
        
        let dateComponents = DateComponents(year: year, month: month, day: 30)
        guard let date = Calendar.current.date(from: dateComponents) else {
            throw NSError(domain: "InvalidDateError", code: 0, userInfo: nil)
        }
        
        let newExpenses = transaction.expensesTransactions.filter { newExpense in
            newExpense.dueDate < date && !expensesTransactions.contains(where: { $0.id == newExpense.id })
        }
        
        let newIncome = transaction.incomeTransactions.filter { newIncome in
            newIncome.dueDate < date && !incomeTransactions.contains(where: { $0.id == newIncome.id })
        }

        expensesTransactions.append(contentsOf: newExpenses)
        incomeTransactions.append(contentsOf: newIncome)
        
        recuringTransactions = transaction.expensesTransactions + transaction.incomeTransactions

        // Fetch totals for current month income and expenses
        let incomeCurrent = try await getTotal(collection: "incomes", month: month, year: year)
        let expenseCurrent = try await getTotal(collection: "expenses", month: month, year: year)

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
    
    func totalAmount(for transactions: [ExpenseModel]) -> Double {
        return transactions.reduce(0.0) { (result, val) in
            if let amountDouble = Double(val.valueBRL) {
                return result + amountDouble
            }
            return result
        }
    }
    
    func createExpenseModel(from data: [String: Any], documentId: String) -> ExpenseModel? {
        guard let typeString = data["type"] as? String,
              let amount = data["amount"] as? String,
              let name = data["name"] as? String,
              let dateTimestamp = data["date"] as? Timestamp,
              let isRecurringValue = data["isRecurring"] as? Int,
              let recurrenceMonths = data["recurrenceMonths"] as? Int,
              let description = data["description"] as? String,
              let categoryId = data["categoryId"] as? String,
              let icon = data["icon"] as? String,
              let transactionType = TransactionType(rawValue: typeString) else {
            return nil
        }
        
        return ExpenseModel(
            transactionID: documentId,
            type: transactionType,
            name: name,
            icon: icon,
            description: description,
            color: .blue,
            valueBRL: amount,
            dueDate: dateTimestamp.dateValue(),
            isPaid: false,
            selectedCategoryId: categoryId,
            isRecurring: isRecurringValue == 1,
            recurrenceMonths: recurrenceMonths
        )
    }
    
    // MARK: - Create Expense
    
    func createTransaction(
        data: [String: Any],
        type: TransactionType,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        
        var payload = data
        payload["created_at"] = Timestamp(date: Date())
        payload["updated_at"] = Timestamp(date: Date())
        payload["user_id"] = UserRepository.shared.loadUser()?.id ?? ""
        
        var documentReference: DocumentReference?
        
        documentReference = db.collection(type == .expense ? "expenses" : "incomes").addDocument(data: payload) { error in
            if let error = error {
                print("\(type.rawValue) failure creating ", error.localizedDescription)
                completion(.failure(error))
            } else if let documentId = documentReference?.documentID {
                print("\(type.rawValue) created successfully: ", payload)
                completion(.success(documentId))
            } else {
                completion(.success(""))
            }
        }
    }
    
    func createRecuringTransaction(
        data: [String: Any],
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        var payload = data
        payload["created_at"] = Timestamp(date: Date())
        payload["updated_at"] = Timestamp(date: Date())
        payload["user_id"] = UserRepository.shared.loadUser()?.id ?? ""
        
        db.collection("recurring").addDocument(data: payload) { error in
            if let error = error {
                
                completion(.failure(error))
            } else {
                
                completion(.success(()))
            }
        }
    }
    
    func fetchRecuringTransactions() async throws -> Transactions {
        var transactions = Transactions(expensesTransactions: [], incomeTransactions: [])
        
        let snap = try await db.collection("recurring")
            .whereField("user_id", isEqualTo: UserRepository.shared.loadUser()?.id ?? "")
            .getDocuments()
        
        if snap.documents.isEmpty {
            print("Transactions are empty")
            return transactions
        }
        
        for document in snap.documents {
            let data = document.data()
            
            if let transaction = self.createExpenseModel(from: data, documentId: document.documentID) {
                if transaction.type == .expense {
                    transactions.expensesTransactions.append(transaction)
                } else {
                    transactions.incomeTransactions.append(transaction)
                }
            }
        }
        
        return transactions
    }
    
    // MARK: - Update Expense or Income
    
    func updateDocument(
        collection: String,
        documentId: String,
        updates: [String: Any],
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        
        var payload = updates
        payload["updated_at"] = Timestamp(date: Date())
        
        db.collection(collection)
            .document(documentId)
            .updateData(payload) { error in
                if let error = error {
                    print("failure updating: ", error.localizedDescription)
                    completion(.failure(error))
                } else {
                    print("updated successfully: ", payload)
                    completion(.success(()))
                }
            }
    }
    
    func deleteDocument(
        collection: String,
        documentId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        db.collection(collection)
            .document(documentId)
            .delete { error in
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
}
