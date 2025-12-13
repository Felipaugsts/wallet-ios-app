//
//  LanguageManager.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 11/10/25.
//

import SwiftUI

@Observable
class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    var language: SelectedLanguage
    

    init() { language = .english }

    func saveLanguage(_ language: SelectedLanguage) {
        self.language = language
    }
}

// MARK: - Enums

public enum SelectedLanguage: String {
    case english = "en"
    case portuguese = "pt-BR"
    
    var locale: Locale {
        switch self {
        case .english:
            return Locale(identifier: "en")
        case .portuguese:
            return Locale(identifier: "pt-BR")
        }
    }
}

struct TextValue {
    static let dashboard = "dashboard"
    static let remainingBalance = "remaining_balance"
    static let vsPreviousMonth = "vs_previous_month"
    static let incomes = "incomes"
    static let expenses = "expenses"
    static let investments = "investments"
    static let totalInvested = "total_invested"
    static let dividendsReceived = "dividends_received"
    static let creditCards = "credit_cards"
    static let dueDate = "due_date"
    static let paid = "paid"
    static let pay = "pay"
    static let transactionHistory = "transaction_history"
    static let dashboardTitle = "dashboardTitle"
    static let settingsTitle = "settingsTitle"
}
