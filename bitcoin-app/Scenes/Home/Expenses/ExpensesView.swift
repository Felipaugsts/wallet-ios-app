//
//  ExpensesView.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 14/12/25.
//

import SwiftUI

struct SubscriptionManagerView: View {
    @StateObject var viewModel: ExpensesViewModel
    @EnvironmentObject var dashboardViewModel: DashboardViewModel
    var preSelectedTransactionType: TransactionType
    
    init(preSelectedTransactionType: TransactionType) {
        self.preSelectedTransactionType = preSelectedTransactionType
        
        self._viewModel = StateObject(wrappedValue: ExpensesViewModel(
            transactionsType: .expense, // Use um valor padrão temporário
            datasource: [],
            loading: false
        ))
    }
    var totalMonthly: Double {
        viewModel.datasource.reduce(0) { $0 + (Double($1.valueBRL) ?? 0) }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                MonthlySummaryCard(totalMonthly: totalMonthly)
                
                SubscriptionList()
            }
            .padding(.vertical)
            .shimmer(when: $viewModel.loading)
        }
        .environmentObject(viewModel)
        .scrollBounceBehavior(.basedOnSize)
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(viewModel.isLoading ? "" : viewModel.transactionsType == .expense ? "Expenses" : "Income")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { viewModel.showingAddSubscription = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(viewModel.transactionsType == .expense ? Color.red : Color.green)
                }
            }
        }
        .fullScreenCover(isPresented: $viewModel.showingAddSubscription) {
            viewModel.editValue = nil
        } content: {
            AddTransactionSheet(editTransaction: viewModel.editValue,
                                preSelectedValueType: viewModel.transactionsType,
                                preSelectedCategoryId: "",
                                delegate: viewModel)
            .environmentObject(dashboardViewModel)
        }
        .onAppear {
            viewModel.transactionsType = preSelectedTransactionType
            viewModel.datasource = preSelectedTransactionType == .expense ?
            dashboardViewModel.overView?.expensesTransactions ?? [] :
            dashboardViewModel.overView?.incomeTransactions ?? []
            viewModel.currentDate = dashboardViewModel.currentDate
            viewModel.delegate = dashboardViewModel
        }
    }
}

struct MonthlySummaryCard: View {
    var totalMonthly: Double
    @EnvironmentObject var viewModel: ExpensesViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("montlyTotalAmount".localized)
                        .font(.subheadline)
                        .foregroundColor(ColorPalette.light.opacity(0.8))
                    Text("$\(totalMonthly, specifier: "%.2f")")
                        .font(.system(size: 34, weight: .bold))
                }
                Spacer()
                SummaryCircle(transactionsType: viewModel.transactionsType)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.categories) { category in
                        CategoryPillSub(category: category, isSelected: viewModel.selectedCategory == category.id) {
                            withAnimation {
                                if viewModel.selectedCategory == category.id {
                                    viewModel.selectedCategory = ""
                                    return
                                }
                                
                                viewModel.selectedCategory = category.id
                            }
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding()
        .background(ColorPalette.backgroundView)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.105), radius: 2)
        .padding(.horizontal)
    }
}

struct SummaryCircle: View {
    var transactionsType: TransactionType
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color.secondary.opacity(0.2),
                    lineWidth: 4)
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(transactionsType == .expense ? Color.red : Color.green,
                        style: StrokeStyle(
                            lineWidth: 4,
                            lineCap: .round
                        ))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 50, height: 50)
    }
}

struct SubscriptionList: View {
    @EnvironmentObject var viewModel: ExpensesViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            
            if viewModel.datasource.isEmpty {
                
                ContentUnavailableView {
                    Label(TextValue.emptyValuesTitle.localized, systemImage: "pencil.and.list.clipboard")
                } description: {
                    Text(TextValue.addExpense.localized)
                } actions: {
                    Button(TextValue.addExpense.localized) {
                        viewModel.showingAddSubscription = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            
            ForEach(viewModel.filteredDatasource) { item in
                Menu {
                    Button(TextValue.cloneNextMonth.localized) { }
                    
                    Button(action: {
                        viewModel.editTransaction(value: item)
                    }) {
                        Label(TextValue.edit.localized, systemImage: "pencil")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive, action: {
                        viewModel.handleDeleteAction(item: item)
                    }) {
                        Label(TextValue.delete.localized, systemImage: "trash")
                    }
                } label: {
                    SubscriptionRow(subscription: item)
                }
            }
        }
        .padding(.horizontal)
        .alert(TextValue.confirmDeleteTitle.localized, isPresented: $viewModel.showAlert) {
            Button(TextValue.confirmDeleteYes.localized) {
                if let itemToDelete = viewModel.selectedItemToDelete {
                    viewModel.deleteTransaction(id: itemToDelete.id, collection: itemToDelete.isRecurring ? "recurring" : nil)
                }
            }
            
            Button("Deletar apenas deste mês") {
                if let itemToDelete = viewModel.selectedItemToDelete {
                    viewModel.excludeFromCurrentMonth(id: itemToDelete.id)
                }
            }
            
            Divider()
            
            Button(TextValue.confirmDeleteCancel.localized, role: .cancel) { }
        }
    }
}

struct SubscriptionRow: View {
    var subscription: ExpenseModel
    @EnvironmentObject var viewModel: ExpensesViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(ColorPalette.textColor)
                    .frame(width: 48, height: 48)
                
                Image(systemName: subscription.icon)
                    .font(.title2)
                    .foregroundColor(subscription.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(subscription.name)
                    .font(.headline)
                    .foregroundColor(ColorPalette.textColor)
                
                Text(subscription.dueDate, style: .date)
                    .font(.caption)
                    .foregroundColor(ColorPalette.light.opacity(0.8))
                
                Text(viewModel.categories.first(where: {$0.icon == subscription.icon})?.name ?? "")
                    .font(.caption)
                    .foregroundColor(ColorPalette.light.opacity(0.8))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(subscription.valueBRL)
                    .font(.title3)
                    .foregroundColor(ColorPalette.textColor)
                    .bold()
                
                Text(TextValue.monthly.localized)
                    .font(.caption)
                    .foregroundColor(ColorPalette.light.opacity(0.8))
            }
        }
        .padding()
        .background(ColorPalette.backgroundView)
        .cornerRadius(16)
        .shadow(radius: 2)
    }
}

struct CategoryPillSub: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category.id.localized)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(uiColor: .systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

import SwiftUI

// MARK: - Model

struct TransportExpense: Identifiable {
    let id = UUID()
    let title: String
    let date: String
    let amount: Double
    let variation: Double
    let icon: String
}

// MARK: - View

struct TransportDetailView: View {
    
    // MARK: Mock Data
    private let expenses: [TransportExpense] = [
        .init(title: "Uber", date: "23 de dezembro, 2025", amount: 45, variation: 15, icon: "car.fill"),
        .init(title: "Gasolina", date: "18 de dezembro, 2025", amount: 150, variation: 5, icon: "fuelpump.fill"),
        .init(title: "Estacionamento", date: "12 de dezembro, 2025", amount: 20, variation: 2, icon: "parkingsign.circle.fill"),
        .init(title: "Ônibus", date: "4 de dezembro, 2025", amount: 25, variation: 2, icon: "bus.fill")
    ]
    
    private let total: Double = 320
    private let income: Double = 8000
    private let lastMonthDiff: Double = 15
    private let months = ["Novembro", "Mês Atual", "Janeiro"]
       
    @State private var selectedMonthIndex = Calendar.current.component(.month, from: Date()) - 1
    
    var body: some View {
        VStack(spacing: 20) {
            headerCard
            monthSelector
            expensesList
        }
        .padding()
        .navigationTitle("Transporte")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Month Selector
    private var monthSelector: some View {
        Picker("Selecione um mês", selection: $selectedMonthIndex) {
            ForEach(0..<months.count, id: \.self) { index in
                Text(months[index])
                    .tag(index)
            }
        }
        .pickerStyle(.segmented)
        .font(.subheadline)
    }
    
    // MARK: - Header Card
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Total")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(total.toCurrency())
                .font(.largeTitle.bold())
            
            Text("+\(lastMonthDiff.toCurrency()) vs mês passado")
                .font(.caption)
                .foregroundColor(.green)
            
            ProgressView(value: total / income)
                .tint(.blue)
            
            Text("\(Int((total / income) * 100))% da sua renda mensal")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(Color(.secondarySystemBackground)))
    }
    
    // MARK: - Expenses List
    private var expensesList: some View {
        List {
            ForEach(expenses) { expense in
                VStack(spacing: 16) {
                    NavigationLink(destination: ExpenseDetailView(expense: expense)) {
                        expenseRow(expense)
                        
                    }
                }
            }
        }
        .lineSpacing(10)
        .listStyle(.plain)
    }
    
    // MARK: - Expense Row
    private func expenseRow(_ expense: TransportExpense) -> some View {
        HStack(spacing: 12) {
            Image(systemName: expense.icon)
                .foregroundColor(.blue)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title)
                    .font(.headline)
                
                Text(expense.date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(expense.amount.toCurrency())
                    .font(.headline)
                
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up")
                    Text("+\(Int(expense.variation))%")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
        }
    }
}

// MARK: - Expense Detail View (Placeholder)
struct ExpenseDetailView: View {
    let expense: TransportExpense
    
    var body: some View {
        Text("Detalhes para \(expense.title)")
            .font(.title)
            .navigationTitle(expense.title)
            .navigationBarTitleDisplayMode(.inline)
    }
}
