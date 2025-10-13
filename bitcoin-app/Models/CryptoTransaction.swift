import Foundation

struct CryptoTransaction: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let type: TransactionType
    let cryptocurrency: Cryptocurrency
    let amount: Double
    let valueUSD: Double
    let transactionHash: String
    
    enum TransactionType: String, Codable {
        case buy = "Compra"
        case sell = "Venda"
        case transfer = "Transferência"
        case receive = "Recebimento"
    }
}

extension CryptoTransaction {
    static let sampleTransactions: [CryptoTransaction] = [
        CryptoTransaction(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, type: .buy, cryptocurrency: Cryptocurrency.sampleData[0], amount: 0.05, valueUSD: 3000.00, transactionHash: "0x123abc..."),
        CryptoTransaction(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, type: .sell, cryptocurrency: Cryptocurrency.sampleData[1], amount: 0.5, valueUSD: 2000.00, transactionHash: "0x456def..."),
        CryptoTransaction(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, type: .receive, cryptocurrency: Cryptocurrency.sampleData[0], amount: 0.1, valueUSD: 6000.00, transactionHash: "0x789ghi..."),
        CryptoTransaction(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, type: .transfer, cryptocurrency: Cryptocurrency.sampleData[2], amount: 10.0, valueUSD: 7.50, transactionHash: "0x012jkl...")
    ]
}
