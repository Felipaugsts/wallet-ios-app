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
    
    init(transactionID: String,
          type: TransactionType = .expense,
          name: String = "Nova Transação",
          icon: String = "dollarsign.circle",
          description: String = "",
          color: Color = .blue,
          valueBRL: String = "0",
          dueDate: Date = Date(),
          isPaid: Bool = false,
          selectedCategoryId: String = "",
          isRecurring: Bool = false,
          recurrenceMonths: Int = 1) {
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
    }
}

struct FinancialData {
    var expenses: Double
    var incomes: Double
    var invested: Double
    var dividends: Double
    var creditCards: [ExpenseModel]
}
