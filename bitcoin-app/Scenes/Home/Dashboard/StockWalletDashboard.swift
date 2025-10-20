//
//  StockWalletDashboard.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 20/10/25.
//

import SwiftUI

struct StockWalletDashboard: View {
    
    let transactions: [Transaction] = [
        Transaction(name: "Bitcoin", type: "Buy", value: "$10,000", image: "bitcoin_logo"),
        Transaction(name: "Ethereum", type: "Sell", value: "$2,500", image: "ethereum_logo"),
        Transaction(name: "Litecoin", type: "Buy", value: "$300", image: "bitcoin_logo"),
        Transaction(name: "Ripple", type: "Sell", value: "$150", image: "bitcoin_logo"),
        Transaction(name: "Ripple", type: "Sell", value: "$150", image: "bitcoin_logo"),
        Transaction(name: "Ripple", type: "Sell", value: "$150", image: "bitcoin_logo"),
        Transaction(name: "Ripple", type: "Sell", value: "$150", image: "bitcoin_logo"),
        // Adicione mais transações conforme necessário
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                ChartView(
                    chartData: sampleData,
                    currentTap: .constant("7 Days")
                )
                
                Section(
                    header:
                        Text("transactions".localized)
                        .font(.headline)
                        .foregroundColor(ColorPalette.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading)) {
                            List(transactions) { transaction in
                                TransactionCard(transaction: transaction)
                                    .listRowInsets(EdgeInsets())
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 5)
                            }
                            .listStyle(.plain)
                            .background(Color.clear)
                        }
                        .background(ColorPalette.backgroundView)
                
                Spacer()
            }
            .background(ColorPalette.backgroundView)
        }
    }
}
