import SwiftUI

struct CryptoTransactionsView: View {
    var transactions: [CryptoTransaction]
    
    var body: some View {
        NavigationView {
            List(transactions) {
                transaction in
                VStack(alignment: .leading) {
                    HStack {
                        Text(transaction.cryptocurrency.name)
                            .font(.headline)
                        Spacer()
                        Text("\(transaction.type.rawValue)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("\(transaction.amount, specifier: "%.4f") \(transaction.cryptocurrency.symbol.uppercased())")
                            .font(.subheadline)
                        Spacer()
                        Text("$\(transaction.valueUSD, specifier: "%.2f")")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    Text(transaction.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Histórico de Transações")
        }
    }
}

#Preview {
    CryptoTransactionsView(transactions: CryptoTransaction.sampleTransactions)
}
