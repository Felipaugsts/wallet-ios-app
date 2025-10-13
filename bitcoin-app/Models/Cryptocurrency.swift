import Foundation

struct Cryptocurrency: Identifiable, Codable {
    let id = UUID()
    let name: String
    let symbol: String
    let currentPrice: Double
    let marketCap: Double
    let priceChangePercentage24h: Double
    let imageUrl: String?
    // Adicionar mais campos conforme necessário, como histórico de preços para gráficos
}

// Exemplo de dados para visualização
extension Cryptocurrency {
    static let sampleData: [Cryptocurrency] = [
        Cryptocurrency(name: "Bitcoin", symbol: "BTC", currentPrice: 60000.00, marketCap: 1.2, priceChangePercentage24h: 2.5, imageUrl: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png?1547033579"),
        Cryptocurrency(name: "Ethereum", symbol: "ETH", currentPrice: 4000.00, marketCap: 0.4, priceChangePercentage24h: -1.2, imageUrl: "https://assets.coingecko.com/coins/images/279/large/ethereum.png?1595348880"),
        Cryptocurrency(name: "Cardano", symbol: "ADA", currentPrice: 0.75, marketCap: 0.02, priceChangePercentage24h: 5.1, imageUrl: "https://assets.coingecko.com/coins/images/975/large/cardano.png?1547034860"),
        Cryptocurrency(name: "Dogecoin", symbol: "DOGE", currentPrice: 0.15, marketCap: 0.01, priceChangePercentage24h: -0.5, imageUrl: "https://assets.coingecko.com/coins/images/5/large/dogecoin.png?1547792256")
    ]
}
