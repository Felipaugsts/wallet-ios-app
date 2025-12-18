//
//  DashboardViewModel.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 13/12/25.
//

import Foundation
import SwiftUI

class DashboardViewModel: ObservableObject, Observable {
    // MARK: - Published Properties
    // @Published automaticamente notifica a View quando esses valores mudam.
    @Published var currentDate: Date = Date()
    @Published var presentSheed = false
    @Published var preSelectedCategoryId: String = ""
    @Published var preSelectedTransactionType: TransactionType = .income
    @Published var overView: OverviewResult?
    @Published var isLoading: Bool = true
    @Published var disableNextMonthButton: Bool = false
    
    let user = UserRepository.shared.loadUser()
    // MARK: - Computed Properties
    var previousMonthData: FinancialData {
        //        let previousDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate)!
        return FinancialData(expenses: 0, incomes: 0, invested: 0, dividends: 0, creditCards: [])
    }
    
    var balance: Double {
        Double(Int(overView?.incomeTotal ?? 0) - Int(overView?.expenseTotal ?? 0))
    }
    
    var isBalancePositive: Bool {
        balance >= 0
    }
    
    // MARK: - Formatters
    private let currencyFormatter: NumberFormatter = { let f = NumberFormatter(); f.numberStyle = .currency; f.locale = Locale(identifier: "pt_BR"); return f }()
    let monthFormatter: DateFormatter = { let f = DateFormatter(); f.dateFormat = "MMMM yyyy"; f.locale = Locale(identifier: "pt_BR"); return f }()
    let dayMonthFormatter: DateFormatter = { let f = DateFormatter(); f.dateFormat = "dd/MM"; return f }()
    
    // MARK: - Public Methods (Actions)
    
    func navigateMonth(by value: Int) {
        guard let newDate = Calendar.current.date(byAdding: .month, value: value, to: currentDate) else { return }
        let month = getMonthAsInt(from: newDate)
        
        let currentMonth: Int = {
            let month = getMonthAsInt(from: Date())
            if month == 12 { return 1}
            
            return month
        }()
        isLoading = true
        
        DispatchQueue.main.async {
            self.disableNextMonthButton = false
            self.currentDate = newDate
            self.disableNextMonthButton = (month + 1 == currentMonth + 1)
            self.fetchSummary()
        }
    }
    
    func getMonthAsInt(from date: Date) -> Int {
        Calendar.current.component(.month, from: date)
    }
    
    func getYearAsInt(from date: Date) -> Int {
        Calendar.current.component(.year, from: date)
    }
    
    // MARK: - Public Methods (Formatting & Calculations)
    func formatCurrency(_ value: Double) -> String {
        currencyFormatter.string(from: NSNumber(value: value)) ?? "R$ 0,00"
    }
    
    func percentageChange(current: Double, previous: Double) -> String {
        if previous == 0 { return current > 0 ? "+100%" : " " }
        let change = ((current - previous) / previous) * 100
        return String(format: "%@%.1f%%", change >= 0 ? "+" : "", change)
    }
    
    func displayAddNewTransactionSheet(id: String, type: TransactionType) {
        preSelectedCategoryId = id
        preSelectedTransactionType = type
        presentSheed = true
    }
    
    @MainActor
    func fetchSummary() {
        isLoading = true
        let year = getYearAsInt(from: currentDate)
        let month = getMonthAsInt(from: currentDate)
        
        Task {
            do {
                let transactions = try await FirestoreUserService().getUserOverview(month: month, year: year)
                overView = transactions
            } catch {
                print("Error fetching summary: \(error.localizedDescription)")
            }
            
            isLoading = false
        }
    }
}

extension FinancialData {
    static var empty: FinancialData {
        .init(expenses: 0, incomes: 0, invested: 0, dividends: 0, creditCards: [])
    }
}

extension Date {
    func getMonthAsInt() -> Int {
        Calendar.current.component(.month, from: self)
    }
    
    func getYearAsInt() -> Int {
        Calendar.current.component(.year, from: self)
    }
}
