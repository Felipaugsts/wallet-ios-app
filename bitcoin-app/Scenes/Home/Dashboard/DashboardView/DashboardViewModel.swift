//
//  DashboardViewModel.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 13/12/25.
//

import Foundation
import Combine // Necessário para ObservableObject e @Published

class DashboardViewModel: ObservableObject {
    // MARK: - Published Properties
    // @Published automaticamente notifica a View quando esses valores mudam.
    @Published var currentDate: Date = Date.from(year: 2025, month: 12, day: 1) {
        didSet { print("")}
    }
    @Published var presentSheed = false
    @Published var preSelectedCategoryId: String = ""
    @Published var preSelectedTransactionType: TransactionType = .income
    @Published var overView: OverviewResult?
    @Published var isLoading: Bool = true
    
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
        currentDate = newDate
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
    
    func fetchSummary() {
        isLoading = true
        FirestoreUserService().getUserOverview(month: 12,
                                               year: 2025) { result in
            switch result {
            case .success(let response):
                self.overView = response
                
            case .failure(let failure):
                print("Falha firebase", failure)
            }
            
            self.isLoading = false
        }
    }
}

extension FinancialData {
    // Um estado vazio para inicialização segura.
    static var empty: FinancialData {
        .init(expenses: 0, incomes: 0, invested: 0, dividends: 0, creditCards: [])
    }
}
