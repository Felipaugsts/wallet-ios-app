//
//  TransactionsView.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 12/10/25.
//
import SwiftUI

struct TransactionsView: View {
    @State private var searchText = ""
    @State private var selectedFilter: TransactionFilter = .all
    @State private var showingAddTransaction = false
    
    let allTransactions: [Transaction] = [
        Transaction(title: "Salário", category: "Receita", amount: 8500.00, date: Date().addingTimeInterval(-86400)),
        Transaction(title: "Supermercado Extra", category: "Alimentação", amount: -234.50, date: Date()),
        Transaction(title: "Uber - Centro", category: "Transporte", amount: -45.30, date: Date().addingTimeInterval(-172800)),
        Transaction(title: "Netflix", category: "Lazer", amount: -39.90, date: Date().addingTimeInterval(-259200)),
        Transaction(title: "Farmácia", category: "Saúde", amount: -127.80, date: Date().addingTimeInterval(-345600)),
        Transaction(title: "Aluguel", category: "Moradia", amount: -2000.00, date: Date().addingTimeInterval(-432000)),
        Transaction(title: "Freelance", category: "Receita", amount: 1500.00, date: Date().addingTimeInterval(-518400)),
        Transaction(title: "Restaurante", category: "Alimentação", amount: -180.00, date: Date().addingTimeInterval(-604800))
    ]
    
    var filteredTransactions: [Transaction] {
        let filtered = allTransactions.filter { transaction in
            switch selectedFilter {
            case .all:
                return true
            case .income:
                return transaction.amount > 0
            case .expense:
                return transaction.amount < 0
            }
        }
        
        if searchText.isEmpty {
            return filtered
        } else {
            return filtered.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filtros
                Picker("Filtro", selection: $selectedFilter) {
                    Text("Todas").tag(TransactionFilter.all)
                    Text("Receitas").tag(TransactionFilter.income)
                    Text("Despesas").tag(TransactionFilter.expense)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Lista de Transações
                if filteredTransactions.isEmpty {
                    EmptyStateView()
                } else {
                    List {
                        ForEach(groupedTransactions, id: \.key) { section in
                            Section(header: Text(section.key)) {
                                ForEach(section.value) { transaction in
                                    TransactionDetailRowView(transaction: transaction)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Transações")
            .searchable(text: $searchText, prompt: "Buscar transações")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddTransaction = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView()
            }
        }
    }
    
    // Agrupar transações por data
    var groupedTransactions: [(key: String, value: [Transaction])] {
        let grouped = Dictionary(grouping: filteredTransactions) { transaction in
            formatDate(transaction.date)
        }
        return grouped.sorted { $0.key > $1.key }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: date)
    }
}
