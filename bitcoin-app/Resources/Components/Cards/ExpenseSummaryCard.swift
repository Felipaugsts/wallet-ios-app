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
    let onTapItem: (String) -> Void
    
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
            Text("\(data.porcentageRalatedToIncome) %")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(data.status.color) +
            Text(" da renda mensal")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Divider()
            
            // Items
            ForEach(data.items.prefix(2)) { item in
                Button { } label: {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 35, height: 35)
                                .shadow(color: .black.opacity(0.0205), radius: 1)
                            
                            Image(systemName: item.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .clipShape(Circle())
                        }
                        
                        VStack(alignment: .leading) {
                            Text(item.title)
                                .font(.subheadline)
                                .foregroundColor(ColorPalette.textColor)
                            
                            Text(Date(), format: .dateTime.month(.wide).day(.twoDigits).year(.defaultDigits))
                                .font(.caption2)
                                .foregroundColor(ColorPalette.textColor.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        Text(item.amount.toCurrency())
                            .font(.subheadline)
                            .foregroundColor(ColorPalette.textColor)
                    }
                }
            }
            
            Divider()
            
            HStack {
                Image(systemName: "doc.fill.badge.plus")
                    .frame(width: 24)
                
                Text(data.items.count > 2 ? "Ver todos" : "Adicionar")
                    .font(.caption)
                    .foregroundColor(ColorPalette.textColor)
            }
            .frame(maxWidth: .infinity, idealHeight: 30)
            .onTapGesture {
                onTapItem(data.filter)
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
