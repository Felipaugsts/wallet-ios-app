//
//  Dictionary+Extension.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 20/12/25.
//

import Foundation
import FirebaseFirestore

extension Dictionary where Key == String, Value == Any {
    func createExpenseModel(documentId: String) -> ExpenseModel? {
        guard let typeString = self["type"] as? String,
              let amount = self["amount"] as? String,
              let name = self["name"] as? String,
              let dateTimestamp = self["date"] as? Timestamp,
              let isRecurringValue = self["isRecurring"] as? Int,
              let description = self["description"] as? String,
              let categoryId = self["categoryId"] as? String,
              let icon = self["icon"] as? String,
              let transactionType = TransactionType(rawValue: typeString),
              let year = self["year"] as? Int,
              let month = self["month"] as? Int else {
            return nil
        }
        
        // Trata a data de vencimento
        let dueDate = dateTimestamp.dateValue()

        // Cria a lista de meses excluídos
        let excludedDates: [Date]? = {
            if let excludedRecurring = self["excludedMonths"] as? [Timestamp] {
                return excludedRecurring.compactMap { $0.dateValue() }
            }
            return nil
        }()
        
        let recurringConfig: RecurringConfig = {
            if let recurringDict = self["recurring"] as? [String: Any] {
                // Extraindo os valores do dicionário e convertendo onde necessário
                let isRecurring = recurringDict["isRecurring"] as? Bool ?? false

                // Para excludedMonths, precisamos converter as strings de data para Date
                let excludedMonths: [Date]? = {
                    if let excludedMonthsArray = recurringDict["excludedDates"] as? [String] {
                        print("Excluded months array: \(excludedMonthsArray)") // Verifique o conteúdo
                        let dates = excludedMonthsArray.compactMap { ISO8601DateFormatter().date(from: $0) }
                        print("Converted dates: \(dates)") // Verifique as datas convertidas
                        return dates
                    }
                    return nil
                }()

                // Para excludedFutureDatesFromDate, também é necessário converter
                let excludedFutureDatesFromDate: Date? = {
                    if let futureDateString = recurringDict["excludedFutureDatesFromDate"] as? String {
                        return ISO8601DateFormatter().date(from: futureDateString)
                    }
                    return nil
                }()

                // Retorna uma nova instância de RecurringConfig com os valores extraídos
                return RecurringConfig(
                    id: UUID().uuidString, // Caso você queira gerar um novo ID, ou você pode usar o ID do dicionário se existir.
                    isRecurring: isRecurring,
                    excludedMonths: excludedMonths,
                    excludedFutureDatesFromDate: excludedFutureDatesFromDate
                )
            }
            return RecurringConfig(id: UUID().uuidString, isRecurring: false) // Ou outro valor padrão se não houver configuração de recorrência
        }()
        
        return ExpenseModel(
            transactionID: documentId,
            type: transactionType,
            name: name,
            icon: icon,
            description: description,
            color: .blue, // Ou outro valor padrão, se necessário
            valueBRL: amount,
            dueDate: dueDate,
            isPaid: false, // Supondo que o valor padrão é false
            selectedCategoryId: categoryId,
            isRecurring: isRecurringValue == 1,
            recurrenceMonths: 0,
            recurringEditable: self["recurringEditable"] as? Bool ?? false, // Valor padrão se não estiver presente
            month: month,
            year: year,
            excludedMonths: excludedDates,
            recurring: recurringConfig ?? RecurringConfig(isRecurring: false)
        )
    }
}
