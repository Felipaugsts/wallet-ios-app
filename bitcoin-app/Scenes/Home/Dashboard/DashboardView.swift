//
//  ExpensesCard.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 13/12/25.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
            ScrollView {
                VStack(spacing: 25) {
                    HeaderView(
                        month: viewModel.monthFormatter.string(from: viewModel.currentDate),
                        onNavigate: viewModel.navigateMonth
                    )
                    
                    MainSummaryCard(
                        balance: viewModel.formatCurrency(viewModel.balance),
                        percentageChange: viewModel.percentageChange(current: viewModel.balance, previous: viewModel.previousMonthData.incomes - viewModel.previousMonthData.expenses),
                        isPositive: viewModel.isBalancePositive
                    )

                    DetailedSummaryView(
                        incomes: viewModel.formatCurrency(viewModel.currentMonthData.incomes),
                        incomesChange: viewModel.percentageChange(current: viewModel.currentMonthData.incomes, previous: viewModel.previousMonthData.incomes),
                        expenses: viewModel.formatCurrency(viewModel.currentMonthData.expenses),
                        expensesChange: viewModel.percentageChange(current: viewModel.currentMonthData.expenses, previous: viewModel.previousMonthData.expenses)
                    )
                    
                    investmentsSection
                    creditCardsSection
                    transactionsSection
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.large)
            .background(ColorPalette.black.edgesIgnoringSafeArea(.all))
    
    }
    
    // MARK: - Sections (ainda como computed properties para clareza)
    
    private var investmentsSection: some View {
        TitledSectionView(title: TextValue.investments.localized) {
            let change = viewModel.percentageChange(current: viewModel.currentMonthData.invested, previous: viewModel.previousMonthData.invested)
            ListItemRow(iconName: "chart.pie.fill", iconColor: ColorPalette.orange, title: TextValue.totalInvested.localized, subtitle: change, trailingTopText: viewModel.formatCurrency(viewModel.currentMonthData.invested), trailingTopColor: ColorPalette.textColor)
            Divider().padding(.leading, 60)
            ListItemRow(iconName: "giftcard.fill", iconColor: ColorPalette.orange, title: TextValue.dividendsReceived.localized, subtitle: nil, trailingTopText: viewModel.formatCurrency(viewModel.currentMonthData.dividends), trailingTopColor: ColorPalette.textColor)
        }
    }
    
    private var creditCardsSection: some View {
        TitledSectionView(title: TextValue.creditCards.localized) {
            ForEach($viewModel.currentMonthData.creditCards) { $card in
                let dueDateString = "\(TextValue.dueDate.localized) \(viewModel.dayMonthFormatter.string(from: card.dueDate))"
                ListItemRow(iconName: "creditcard.fill", iconColor: ColorPalette.indigo, title: card.name, subtitle: dueDateString, trailingTopText: viewModel.formatCurrency(card.spent), trailingTopColor: ColorPalette.red) {
                    if card.isPaid { Text(TextValue.paid.localized).font(.caption).bold().foregroundColor(ColorPalette.green) }
                    else { Button(TextValue.pay.localized) { card.isPaid = true }.font(.caption).buttonStyle(.borderedProminent).tint(ColorPalette.blue) }
                }
                if card.id != viewModel.currentMonthData.creditCards.last?.id { Divider().padding(.leading, 60) }
            }
        }
    }
    
    private var transactionsSection: some View {
        TitledSectionView(title: TextValue.transactionHistory.localized) {
            let sortedTransactions = viewModel.currentMonthData.transactions.sorted(by: { $0.date > $1.date })
            ForEach(sortedTransactions) { transaction in
                let isNegative = transaction.value < 0
                let color = isNegative ? ColorPalette.red : ColorPalette.green
                ListItemRow(iconName: transaction.iconName, iconColor: color, title: transaction.category.localized, subtitle: viewModel.dayMonthFormatter.string(from: transaction.date), trailingTopText: viewModel.formatCurrency(transaction.value), trailingTopColor: color)
                if transaction.id != sortedTransactions.last?.id { Divider().padding(.leading, 60) }
            }
        }
    }
}
