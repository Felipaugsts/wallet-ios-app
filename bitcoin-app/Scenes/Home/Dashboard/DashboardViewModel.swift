//
//  DashboardViewModel.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 13/12/25.
//

import Foundation
import Combine // Necessário para ObservableObject e @Published

// O ViewModel é o cérebro da sua View.
class DashboardViewModel: ObservableObject {
    // MARK: - Published Properties
    // @Published automaticamente notifica a View quando esses valores mudam.
    @Published var currentDate: Date = Date.from(year: 2025, month: 12, day: 1) {
        didSet {
            // Quando a data muda, atualizamos os dados do mês.
            updateFinancialData()
        }
    }
    @Published var currentMonthData: FinancialData = .empty
    
    // MARK: - Computed Properties
    var previousMonthData: FinancialData {
        let previousDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate)!
        return mockData[getMonthKey(for: previousDate)] ?? .empty
    }

    var balance: Double {
        currentMonthData.incomes - currentMonthData.expenses
    }
    
    var isBalancePositive: Bool {
        balance >= 0
    }

    // MARK: - Formatters
    private let currencyFormatter: NumberFormatter = { let f = NumberFormatter(); f.numberStyle = .currency; f.locale = Locale(identifier: "pt_BR"); return f }()
    let monthFormatter: DateFormatter = { let f = DateFormatter(); f.dateFormat = "MMMM yyyy"; f.locale = Locale(identifier: "pt_BR"); return f }()
    let dayMonthFormatter: DateFormatter = { let f = DateFormatter(); f.dateFormat = "dd/MM"; return f }()
    
    // MARK: - Initializer
    init() {
        // Carrega os dados iniciais quando o ViewModel é criado.
        updateFinancialData()
    }
    
    // MARK: - Public Methods (Actions)
    func navigateMonth(by value: Int) {
        guard let newDate = Calendar.current.date(byAdding: .month, value: value, to: currentDate) else { return }
        // Apenas navega se houver dados simulados para o mês.
        if mockData[getMonthKey(for: newDate)] != nil {
            currentDate = newDate
        } else {
            print("Não há dados para \(monthFormatter.string(from: newDate))")
        }
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

    // MARK: - Private Helper Methods
    private func updateFinancialData() {
        let key = getMonthKey(for: currentDate)
        self.currentMonthData = mockData[key] ?? .empty
    }
    
    private func getMonthKey(for date: Date) -> String {
        let cal = Calendar.current
        return "\(cal.component(.year, from: date))-\(String(format: "%02d", cal.component(.month, from: date)))"
    }
    
    var mockData: [String: FinancialData] = {
        let dataDec = FinancialData(expenses: 4200.00, incomes: 5500.00, invested: 1500.00, dividends: 75.00, creditCards: [CreditCard(name: "Visa Platinum", available: 5000.00, spent: 1500.00, dueDate: Date.from(year: 2026, month: 1, day: 10), isPaid: false), CreditCard(name: "Mastercard Gold", available: 3000.00, spent: 950.00, dueDate: Date.from(year: 2026, month: 1, day: 15), isPaid: false)], transactions: [TransactionModel(date: Date.from(year: 2025, month: 12, day: 12), category: "Presentes", value: -450.00), TransactionModel(date: Date.from(year: 2025, month: 12, day: 10), category: "Supermercado", value: -400.00), TransactionModel(date: Date.from(year: 2025, month: 12, day: 5), category: "Serviços", value: -150.00), TransactionModel(date: Date.from(year: 2025, month: 12, day: 1), category: "Salário", value: 5500.00), TransactionModel(date: Date.from(year: 2025, month: 12, day: 1), category: "Investimento", value: -1500.00)])
        let dataNov = FinancialData(expenses: 3500.00, incomes: 5000.00, invested: 1000.00, dividends: 50.00, creditCards: [], transactions: [])
        return ["2025-11": dataNov, "2025-12": dataDec]
    }()
}

extension FinancialData {
    // Um estado vazio para inicialização segura.
    static var empty: FinancialData {
        .init(expenses: 0, incomes: 0, invested: 0, dividends: 0, creditCards: [], transactions: [])
    }
}
