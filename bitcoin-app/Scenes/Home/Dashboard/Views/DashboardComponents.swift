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
    let balance: String
    let percentageChange: String
    let isPositive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(TextValue.remainingBalance.localized).font(.title3)
                .foregroundColor(Color.white.opacity(0.8))
            
            Text(balance).font(.largeTitle).fontWeight(.bold)
                .foregroundColor(Color.white)
            
            HStack {
                Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                    .foregroundColor(Color.white)
                
                Text(percentageChange).fontWeight(.medium)
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
    let incomes: String
    let incomesChange: String
    let expenses: String
    let expensesChange: String
    
    var body: some View {
        HStack {
            SummaryDetailCard(title: TextValue.incomes.localized, value: incomes, percentageChange: incomesChange, iconName: "arrow.down.left", color: ColorPalette.green)
            SummaryDetailCard(title: TextValue.expenses.localized, value: expenses, percentageChange: expensesChange, iconName: "arrow.up.right", color: ColorPalette.red)
        }
    }
}

struct TitledSectionView<Content: View>: View {
    let title: String; let content: Content
    init(title: String, @ViewBuilder content: () -> Content) { self.title = title; self.content = content() }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline).foregroundColor(ColorPalette.light).padding(.leading)
            VStack(spacing: 0) { content }.background(ColorPalette.backgroundView200).cornerRadius(15)
        }
    }
}
