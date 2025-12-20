//
//  DashboardModel.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 13/12/25.
//

import SwiftUI

struct ExpenseModel: Identifiable, Hashable {
    var id: String { transactionID }
    var transactionID: String
    var type: TransactionType
    var name: String
    var icon: String
    var description: String
    var color: Color
    var valueBRL: String
    var dueDate: Date
    var isPaid: Bool
    var selectedCategoryId: String
    var isRecurring: Bool
    var recurrenceMonths: Int
    var created_at: Date?
    var recurringEditable: Bool?
    var month: Int
    var year: Int
    var excludedMonths: [Date]?
    
    init(transactionID: String,
         type: TransactionType = .expense,
         name: String = "",
         icon: String = "dollarsign.circle",
         description: String = "",
         color: Color = .blue,
         valueBRL: String = "",
         dueDate: Date = Date(),
         isPaid: Bool = false,
         selectedCategoryId: String = "",
         isRecurring: Bool = false,
         recurrenceMonths: Int = 1,
         created_at: Date? = nil,
         recurringEditable: Bool? = true,
         month: Int = 0,
         year: Int = 0,
         excludedMonths: [Date]? = nil) {
        self.transactionID = transactionID
        self.type = type
        self.name = name
        self.icon = icon
        self.description = description
        self.color = color
        self.valueBRL = valueBRL
        self.dueDate = dueDate
        self.isPaid = isPaid
        self.selectedCategoryId = selectedCategoryId
        self.isRecurring = isRecurring
        self.recurrenceMonths = recurrenceMonths
        self.created_at = created_at
        self.recurringEditable = recurringEditable
        self.month = month
        self.year = year
        self.excludedMonths = excludedMonths
    }
    
    mutating func updateId(_ newId: String) {
        self.transactionID = newId
    }
}

extension ExpenseModel {
    var emptyData: ExpenseModel {
        ExpenseModel(transactionID: "")
    }
    
    func toDict(recurringEditable: Bool = true) -> [String: Any] {
        let dict: [String: Any] = [
               "transactionID": transactionID,
               "type": type.rawValue,
               "name": name,
               "icon": icon,
               "description": description,
               "valueBRL": valueBRL,
               "isPaid": isPaid,
               "selectedCategoryId": selectedCategoryId,
               "isRecurring": isRecurring,
               "recurrenceMonths": recurrenceMonths,
               "categoryId": selectedCategoryId,
               "date": dueDate,
               "amount": valueBRL,
               "month": month,
               "year": year,
               "excludedMonths": excludedMonths
           ]
           return dict
       }
}

struct FinancialData {
    var expenses: Double
    var incomes: Double
    var invested: Double
    var dividends: Double
    var creditCards: [ExpenseModel]
}

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
