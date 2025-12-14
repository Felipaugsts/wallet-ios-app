//
//  DashboardComponents.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 13/12/25.
//

import SwiftUI

struct HeaderView: View {
    let month: String
    let onNavigate: (Int) -> Void
    
    var body: some View {
        HStack {
            Button(action: { onNavigate(-1) }) { Image(systemName: "chevron.left.circle.fill") }
            Spacer()
            Text(month.capitalized).font(.headline).fontWeight(.semibold)
            Spacer()
            Button(action: { onNavigate(1) }) { Image(systemName: "chevron.right.circle.fill") }
        }.font(.title2).foregroundColor(ColorPalette.light).padding(.horizontal, 8)
    }
}

struct MainSummaryCard: View {
    let overview: OverviewResult?
    let isPositive: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(TextValue.remainingBalance.localized).font(.title3)
                .foregroundColor(Color.white.opacity(0.8))
            
            Text("$\(overview?.balance ?? 0, specifier: "%.2f")")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color.white)
            
            HStack {
                Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                    .foregroundColor(Color.white)
                
                Text(String(describing: overview?.balanceChangePercent ?? 0)).fontWeight(.medium)
                    .foregroundColor(Color.white)
                
                Text(TextValue.vsPreviousMonth.localized).font(.caption)
                    .foregroundColor(Color.white.opacity(0.7))
            }
        }.padding(25).frame(
            maxWidth: .infinity,
            alignment: .leading).background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(ColorPalette.purple).shadow(
                        color: .black.opacity(0.2),
                        radius: 10, x: 0, y: 5
                    )
            )
    }
}

struct DetailedSummaryView: View {
    let overview: OverviewResult?
    
    var body: some View {
        HStack {
            
            NavigationLink {
                SubscriptionManagerView(transactionsType: .income, datasource: overview?.incomeTransactions)
            } label: {
                SummaryDetailCard(title: TextValue.incomes.localized, value: String(describing: overview?.incomeTotal ?? 0),
                                  percentageChange: String(describing: overview?.incomeChangePercent ?? 0),
                                  iconName: "arrow.down.left",
                                  color: ColorPalette.green)
            }
            
            NavigationLink {
                SubscriptionManagerView(transactionsType: .expense, datasource: overview?.expensesTransactions)
            } label: {
                SummaryDetailCard(title: TextValue.expenses.localized,
                                  value: String(describing: overview?.expenseTotal ?? 0),
                                  percentageChange: String(describing: overview?.expenseChangePercent ?? 0),
                                  iconName: "arrow.up.right", color: ColorPalette.red)
            }
        }
    }
}

struct TitledSectionView<Content: View>: View {
    let title: String; let content: Content
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title; self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title).font(.headline).foregroundColor(ColorPalette.light).padding(.leading)
            }
            VStack(spacing: 0) { content }.background(ColorPalette.backgroundView200).cornerRadius(15)
        }
    }
}
