//
//  Dictionary+Extension.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 20/12/25.
//

import Foundation
import FirebaseFirestore // Certifique-se de importar o módulo apropriado se estiver usando Timestamp

extension Dictionary where Key == String, Value == Any {
    func createExpenseModel(documentId: String) -> ExpenseModel? {
        guard let typeString = self["type"] as? String,
              let amount = self["amount"] as? String,
              let name = self["name"] as? String,
              let dateTimestamp = self["date"] as? Timestamp,
              let isRecurringValue = self["isRecurring"] as? Int,
              let recurrenceMonths = self["recurrenceMonths"] as? Int,
              let description = self["description"] as? String,
              let categoryId = self["categoryId"] as? String,
              let icon = self["icon"] as? String,
              let transactionType = TransactionType(rawValue: typeString),
              let year = self["year"] as? Int,
              let month = self["month"] as? Int else {
            return nil
        }
        
        var excludedDates: [Date] = []
        
        if let excludedRecurring = self["excludedMonths"] as? [Timestamp] {
            excludedDates = excludedRecurring.compactMap { $0.dateValue() }
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
            recurrenceMonths: recurrenceMonths,
            recurringEditable: self["recurringEditable"] as? Bool,
            month: month,
            year: year,
            excludedMonths: excludedDates.isEmpty ? nil : excludedDates
        )
    }
}
