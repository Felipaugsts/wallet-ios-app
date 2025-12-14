//
//  DashboardService.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 13/12/25.
//

import Foundation
import FirebaseFirestore


struct OverviewResult {
    let incomeTotal: Double
    let expenseTotal: Double
    let balance: Double

    let incomeChangePercent: Double
    let expenseChangePercent: Double
    let balanceChangePercent: Double
}

final class FirestoreUserService {

    // MARK: - Properties

    private let db = Firestore.firestore()

    // MARK: - User Overview (Month)

    func getMontlyExpenses(month: Int, year: Int, completion: @escaping (Result<[TransactionTypeModel], Error>) -> Void) {
        db.collection("expenses")
            .whereField("user_id", isEqualTo: "FJN3yYhhiRYJZlWHefhaCV9L2xE3")
            .whereField("month", isEqualTo: month)
            .whereField("year", isEqualTo: year)
            .getDocuments(completion: { snapshot, error in
                var transactions: [TransactionTypeModel] = []
                
                guard let documents = snapshot?.documents else {
                    let noDataError = NSError(domain: "FirestoreError", code: 404, userInfo: [NSLocalizedDescriptionKey: "No data found"])
                    completion(.failure(noDataError))
                    return
                }
                
                for document in documents {
                    let data = document.data()
                    print(data)
                    
                    guard let typeString = data["type"] as? String,
                          let amount = data["amount"] as? Double,
                          let name = data["name"] as? String,
                          let dateTimestamp = data["date"] as? Timestamp,
                          let isRecurringValue = data["isRecurring"] as? Int,
                          let recurrenceMonths = data["recurrenceMonths"] as? Int,
                          let description = data["description"] as? String,
                          let categoryId = data["categoryId"] as? String
                      else {
                        continue
                    }
                    
                    guard let transactionType = TransactionType(rawValue: typeString) else {
                        continue
                    }
                    
                    let date = dateTimestamp.dateValue()
                    
                    let isRecurring = isRecurringValue == 1
                    
                
                    let transaction = TransactionTypeModel(type: transactionType,
                                                           name: name,
                                                           description: description,
                                                           amount: amount,
                                                           categoryId: categoryId,
                                                           date: date,
                                                           isRecurring: isRecurring,
                                                           recurrenceMonths: recurrenceMonths)
                    transactions.append(transaction)
                }
                print("transactions123", transactions)
                completion(.success(transactions))
            })
    }
    
    func getUserOverview(
        userId: String,
        month: Int,
        year: Int,
        completion: @escaping (Result<OverviewResult, Error>) -> Void
    ) {

        func previousMonth(month: Int, year: Int) -> (Int, Int) {
            if month == 1 { return (12, year - 1) }
            return (month - 1, year)
        }

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
                    let total = snap?.documents.reduce(0.0) {
                        $0 + ($1.data()["amount"] as? Double ?? 0)
                    } ?? 0
                    completion(total)
                }
        }

        let (prevMonth, prevYear) = previousMonth(month: month, year: year)
        let group = DispatchGroup()

        var incomeCurrent = 0.0
        var expenseCurrent = 0.0
        var incomePrev = 0.0
        var expensePrev = 0.0

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

        group.enter()
        getTotal(collection: "incomes", month: prevMonth, year: prevYear) {
            incomePrev = $0
            group.leave()
        }

        group.enter()
        getTotal(collection: "expenses", month: prevMonth, year: prevYear) {
            expensePrev = $0
            group.leave()
        }

        group.notify(queue: .main) {

            func percentChange(current: Double, previous: Double) -> Double {
                guard previous != 0 else {
                    return current == 0 ? 0 : 100
                }
                return ((current - previous) / previous) * 100
            }

            let balanceCurrent = incomeCurrent - expenseCurrent
            let balancePrev = incomePrev - expensePrev

            let result = OverviewResult(
                incomeTotal: incomeCurrent,
                expenseTotal: expenseCurrent,
                balance: balanceCurrent,
                incomeChangePercent: percentChange(current: incomeCurrent, previous: incomePrev),
                expenseChangePercent: percentChange(current: expenseCurrent, previous: expensePrev),
                balanceChangePercent: percentChange(current: balanceCurrent, previous: balancePrev)
            )

            completion(.success(result))
        }
    }

    // MARK: - Create Expense

    func createExpense(
        data: [String: Any],
        completion: @escaping (Result<String, Error>) -> Void
    ) {

        var payload = data
        payload["created_at"] = Timestamp(date: Date())
        payload["updated_at"] = Timestamp(date: Date())

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
}
