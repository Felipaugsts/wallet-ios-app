import Foundation

struct CryptoWallet: Identifiable, Codable {
    let id = UUID()
    var holdings: [CryptoHolding]
    var totalBalanceUSD: Double {
        holdings.reduce(0) { $0 + ($1.cryptocurrency.currentPrice * $1.amount) }
    }
}

struct CryptoHolding: Identifiable, Codable {
    let id = UUID()
    let cryptocurrency: Cryptocurrency
    var amount: Double
    var valueUSD: Double {
        cryptocurrency.currentPrice * amount
    }
}

// Exemplo de dados para visualização
extension CryptoWallet {
    static let sampleWallet: CryptoWallet = {
        var holdings: [CryptoHolding] = []
        if let bitcoin = Cryptocurrency.sampleData.first(where: { $0.symbol == "BTC" }) {
            holdings.append(CryptoHolding(cryptocurrency: bitcoin, amount: 0.5))
        }
        if let ethereum = Cryptocurrency.sampleData.first(where: { $0.symbol == "ETH" }) {
            holdings.append(CryptoHolding(cryptocurrency: ethereum, amount: 2.0))
        }
        return CryptoWallet(holdings: holdings)
    }()
}
