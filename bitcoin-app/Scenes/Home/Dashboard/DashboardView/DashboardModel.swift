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
    var recurring: RecurringConfig
    
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
         excludedMonths: [Date]? = nil,
         recurring: RecurringConfig) {
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
        self.recurring = recurring
    }
    
    mutating func updateId(_ newId: String) {
        self.transactionID = newId
    }
}

struct RecurringConfig: Codable, Identifiable, Hashable {
    var id: String
    var isRecurring: Bool
    var excludedMonths: [Date]?
    var excludedFutureDatesFromDate: Date?
    
    init(id: String = UUID().uuidString,
         isRecurring: Bool,
         excludedMonths: [Date]? = nil,
         excludedFutureDatesFromDate: Date? = nil) {
        self.id = id
        self.isRecurring = isRecurring
        self.excludedMonths = excludedMonths
        self.excludedFutureDatesFromDate = excludedFutureDatesFromDate
    }
    
    mutating func addExcludedMonth(_ date: Date) {
        if excludedMonths == nil {
            excludedMonths = [date]
        } else {
            excludedMonths?.append(date)
        }
    }
    
    mutating func addExcludedFutureDatesFromDate(_ date: Date) {
        excludedFutureDatesFromDate = date
    }
}

extension ExpenseModel {
    var emptyData: ExpenseModel {
        ExpenseModel(transactionID: "", recurring: RecurringConfig(isRecurring: false))
    }
    
    func toDict(recurringEditable: Bool = true) -> [String: Any] {
        var dict: [String: Any] = [
            "transactionID": transactionID,
            "type": type.rawValue,
            "name": name,
            "icon": icon,
            "description": description,
            "amount": valueBRL,
            "isPaid": isPaid,
            "categoryId": selectedCategoryId,
            "isRecurring": isRecurring,
            "month": month,
            "year": year
        ]
        
        // Adiciona a data de vencimento formatada
        let dateFormatter = ISO8601DateFormatter()
        dict["date"] = dueDate
        
        if let created_at = created_at {
            dict["created_at"] = dateFormatter.string(from: created_at)
        }
        
        // Adiciona a propriedade de edição recorrente (se existir)
        dict["recurringEditable"] = recurringEditable
        
        // Adiciona a configuração de recorrência
        dict["recurring"] = recurring.toDict(excludedDates: self.excludedMonths ?? [])
        
        return dict
    }
}

// Extensão para a estrutura RecurringConfig
extension RecurringConfig {
    func toDict(excludedDates: [Date] = []) -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "isRecurring": isRecurring
        ]
        
        if let excludedMonths = excludedMonths {
            let dateFormatter = ISO8601DateFormatter()
            let formattedMonths = excludedMonths.map { dateFormatter.string(from: $0) }
            
            if var existingMonths = dict["excludedMonths"] as? [String] {
                existingMonths.append(contentsOf: formattedMonths)
                dict["excludedMonths"] = existingMonths // Atualiza o dicionário
            } else {
                dict["excludedMonths"] = formattedMonths // Cria nova entrada
            }
        }
        
        if !excludedDates.isEmpty {
            let dateFormatter = ISO8601DateFormatter()
            let formattedDates = excludedDates.map { dateFormatter.string(from: $0) }
            
            if var existingDates = dict["excludedDates"] as? [String] {
                existingDates.append(contentsOf: formattedDates)
                dict["excludedDates"] = existingDates
            } else {
                dict["excludedDates"] = formattedDates
            }
        }
        
        if let excludedFutureDatesFromDate = excludedFutureDatesFromDate {
            let dateFormatter = ISO8601DateFormatter()
            dict["excludedFutureDatesFromDate"] = dateFormatter.string(from: excludedFutureDatesFromDate)
        }

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
