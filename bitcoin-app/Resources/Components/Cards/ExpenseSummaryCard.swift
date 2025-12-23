////
////  ExpenseSummaryCard.swift
////  bitcoin-app
////
////  Created by Felipe Augusto Silva on 22/12/25.
////

import SwiftUI

enum SummaryStatus: Codable {
    case normal
    case warning
    case danger
    
    var color: Color {
        switch self {
        case .normal: return .green
        case .warning: return .orange
        case .danger: return .red
        }
    }
}
//
struct FinancialSummaryCard: View {
    let data: ExpensesSummaryModel
    let onTapItem: (SummaryItem) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Header
            HStack {
                Text(data.title)
                    .font(.headline)
                
                Spacer()
                
                Text(data.totalAmount.toCurrency())
                    .font(.headline)
            }
            
            Text("Consome ")
                .font(.caption)
                .foregroundStyle(.secondary) +
            Text("\(data.porcentageRalatedToIncome)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(data.status.color) +
            Text(" da renda mensal")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Divider()
            
            // Items
            ForEach(data.items.prefix(2)) { item in
                Button {
                    onTapItem(item)
                } label: {
                    HStack {
                        Image(systemName: item.icon)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading) {
                            Text(item.title)
                                .font(.subheadline)
                                .foregroundColor(ColorPalette.textColor)
                            
                            Text(Date(), format: .dateTime.month(.wide).day(.twoDigits).year(.defaultDigits))
                                .font(.caption)
                                .foregroundColor(ColorPalette.textColor.opacity(0.5))
                        }
                        
                        Spacer()
                        
                        Text(item.amount.toCurrency())
                            .font(.subheadline)
                            .foregroundColor(ColorPalette.textColor)
                    }
                }
            }
            
            if data.items.count > 2 {
                Divider()
                
                HStack {
                    Image(systemName: "doc.fill.badge.plus")
                        .frame(width: 24)
                    
                    Text("Ver todos")
                        .font(.caption)
                        .foregroundColor(ColorPalette.textColor)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(ColorPalette.backgroundView200)
        )
        .shadow(color: .black.opacity(0.105), radius: 2)
    }
}


extension Double {
    func toCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: self)) ?? "R$ 0,00"
    }
}
