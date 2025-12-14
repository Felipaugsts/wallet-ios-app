//
//  ExpensesView.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 14/12/25.
//

import SwiftUI

struct SubscriptionManagerView: View {
    var transactionsType: TransactionType
    var datasource: [ExpenseModel]?
    @State private var selectedCategory: Category?
    @StateObject var viewModel = ExpensesViewModel()
    
    var totalMonthly: Double {
        viewModel.datasource.reduce(0) { $0 + (Double($1.valueBRL) ?? 0) }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                MonthlySummaryCard(totalMonthly: totalMonthly,
                                   transactionsType: viewModel.transactionsType,
                                   categories: viewModel.categories,
                                   selectedCategory: $selectedCategory)
                
                SubscriptionList(subscriptions: filteredSubscriptions) { id in
                    viewModel.deleteTransaction(id: id)
                } edit: { transaction in
                    viewModel.editTransaction(value: transaction)
                }
            }
            .padding(.vertical)
            .shimmer(when: $viewModel.loading)
        }
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
        .task {
            viewModel.transactionsType = transactionsType
            viewModel.datasource = datasource ?? []
            viewModel.loading = false
        }
        .fullScreenCover(isPresented: $viewModel.showingAddSubscription) {
            viewModel.editValue = nil
        } content: {
            AddTransactionSheet(editTransaction: viewModel.editValue,
                                preSelectedValueType: viewModel.transactionsType,
                                preSelectedCategoryId: "",
                                delegate: viewModel)
        }
    }
    
    var filteredSubscriptions: [ExpenseModel] {
        guard let category = selectedCategory else { return viewModel.datasource}
        return viewModel.datasource.filter { $0.type.rawValue == category.name }
    }
}

struct MonthlySummaryCard: View {
    var totalMonthly: Double
    var transactionsType: TransactionType
    var categories: [Category]
    @Binding var selectedCategory: Category?

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Monthly Total")
                        .font(.subheadline)
                        .foregroundColor(ColorPalette.light.opacity(0.8))
                    Text("$\(totalMonthly, specifier: "%.2f")")
                        .font(.system(size: 34, weight: .bold))
                }
                Spacer()
                SummaryCircle(transactionsType: transactionsType)
            }
            
            // Category pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories) { category in
                        CategoryPillSub(category: category, isSelected: selectedCategory == category) {
                            withAnimation {
                                selectedCategory = selectedCategory == category ? nil : category
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
        .shadow(radius: 2)
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
    var subscriptions: [ExpenseModel]
    var delete: (_ id: String) -> Void
    var edit: (_ transaction: ExpenseModel) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(subscriptions) { subscription in
                Menu {
                    Button(action: {
                        edit(subscription)
                    }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: {
                        delete(subscription.id)
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    SubscriptionRow(subscription: subscription)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct SubscriptionRow: View {
    var subscription: ExpenseModel
    
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
                
                Text(subscription.type.rawValue)
                    .font(.caption)
                    .foregroundColor(ColorPalette.light.opacity(0.8))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(subscription.valueBRL)
                    .font(.title3)
                    .foregroundColor(ColorPalette.textColor)
                    .bold()
                
                Text("Monthly")
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
            Text(category.name)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(uiColor: .systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}
