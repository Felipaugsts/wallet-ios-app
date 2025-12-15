//
//  DashboardService.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 13/12/25.
//

import Foundation
import FirebaseFirestore
import SwiftUICore


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
}

final class FirestoreUserService {
    
    // MARK: - Properties
    
    private let db = Firestore.firestore()
    
    // MARK: - User Overview (Month)
    
    func getUserOverview(
        month: Int,
        year: Int,
        completion: @escaping (Result<OverviewResult, Error>) -> Void
    ) {
        let userId = UserRepository.shared.loadUser()?.id ?? ""
        func previousMonth(month: Int, year: Int) -> (Int, Int) {
            if month == 1 { return (12, year - 1) }
            return (month - 1, year)
        }
        
        var expensesTransactions: [ExpenseModel] = []
        var incomeTransactions: [ExpenseModel] = []
        
        func getTotal(
            collection: String,
            month: Int,
            year: Int,
            completion: @escaping (Double) -> Void
        ) {
            db.collection(collection)
                .whereField("user_id", isEqualTo: userId)
                .whereField("month", isEqualTo: month)
                .whereField("year", isEqualTo: year)
                .getDocuments { snap, _ in
                    if let documents = snap?.documents {
                        for document in documents {
                            let data = document.data()
                            let eventDate = data["date"] as? Timestamp
                            let date = eventDate?.dateValue() ?? Date()
                            
                            if Calendar.current.component(.month, from: date) != month {
                                return
                            }
                            
                            if let transaction = self.createExpenseModel(from: data, documentId: document.documentID) {
                                if collection == "expenses" {
                                    expensesTransactions.append(transaction)
                                } else {
                                    incomeTransactions.append(transaction)
                                }
                            }
                        }
                    }
                    
                    let total = snap?.documents.reduce(0.0) { (result, document) in
                        let data = document.data()
                        if let amountString = data["amount"] as? String,
                           let amountDouble = Double(amountString) {
                            return result + amountDouble
                        }
                        return result
                    } ?? 0.0
                    completion(total)
                }
        }
        
        let group = DispatchGroup()
        
        var incomeCurrent = 0.0
        var expenseCurrent = 0.0
        
        group.enter()
        getTotal(collection: "incomes", month: month, year: year) {
            incomeCurrent = $0
            group.leave()
        }
        
        group.enter()
        getTotal(collection: "expenses", month: month, year: year) {
            expenseCurrent = $0
            group.leave()
        }
        
        group.notify(queue: .main) {
            
            let balanceCurrent = incomeCurrent - expenseCurrent
            
            let result = OverviewResult(
                incomeTotal: incomeCurrent,
                expenseTotal: expenseCurrent,
                balance: balanceCurrent,
                incomeChangePercent: 0,
                expenseChangePercent: 0,
                balanceChangePercent: 0,
                totalInvestedValue: 0,
                currentMonthDividends: 0,
                expensesTransactions: expensesTransactions,
                incomeTransactions: incomeTransactions
            )
            
            completion(.success(result))
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
    
    func createExpense(
        data: [String: Any],
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        
        var payload = data
        payload["created_at"] = Timestamp(date: Date())
        payload["updated_at"] = Timestamp(date: Date())
        payload["user_id"] = UserRepository.shared.loadUser()?.id ?? ""
        
        db.collection("expenses").addDocument(data: payload) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("expense_created"))
            }
        }
    }
    
    // MARK: - Create Income
    
    func createIncome(
        data: [String: Any],
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        
        var payload = data
        payload["created_at"] = Timestamp(date: Date())
        payload["updated_at"] = Timestamp(date: Date())
        payload["user_id"] = UserRepository.shared.loadUser()?.id ?? ""
        
        db.collection("incomes").addDocument(data: payload) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("income_created"))
            }
        }
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
                    completion(.failure(error))
                } else {
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
