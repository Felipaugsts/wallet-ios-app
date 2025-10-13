import SwiftUI
import Charts

struct DashboardView: View {
    @State private var cryptoWallet: CryptoWallet = CryptoWallet.sampleWallet
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Saldo Total da Carteira
                    VStack(alignment: .leading) {
                        Text("Saldo Total da Carteira")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("$\(cryptoWallet.totalBalanceUSD, specifier: "%.2f")")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Gráfico Principal (exemplo com Bitcoin)
                    if let bitcoinHolding = cryptoWallet.holdings.first(where: { $0.cryptocurrency.symbol == "BTC" }) {
                        CryptoChartView(
                            priceHistory: [
                                PricePoint(date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, price: bitcoinHolding.cryptocurrency.currentPrice * 0.95),
                                PricePoint(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, price: bitcoinHolding.cryptocurrency.currentPrice * 1.02),
                                PricePoint(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, price: bitcoinHolding.cryptocurrency.currentPrice * 0.98),
                                PricePoint(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, price: bitcoinHolding.cryptocurrency.currentPrice * 1.05),
                                PricePoint(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, price: bitcoinHolding.cryptocurrency.currentPrice * 1.01),
                                PricePoint(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, price: bitcoinHolding.cryptocurrency.currentPrice * 1.03),
                                PricePoint(date: Date(), price: bitcoinHolding.cryptocurrency.currentPrice)
                            ],
                            cryptocurrencyName: bitcoinHolding.cryptocurrency.name
                        )
                        .padding(.horizontal)
                    }
                    
                    // Lista de Criptomoedas/Ativos
                    VStack(alignment: .leading) {
                        Text("Meus Ativos")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.leading)
                        
                        ForEach(cryptoWallet.holdings) {
                            holding in
                            CryptoAssetRow(holding: holding)
                        }
                    }
                    .padding(.vertical)
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
            .navigationTitle("Minha Wallet")
            .navigationBarHidden(true)
        }
    }
}

struct CryptoAssetRow: View {
    var holding: CryptoHolding
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: holding.cryptocurrency.imageUrl ?? "")) {
                image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(holding.cryptocurrency.name)
                    .font(.headline)
                Text(holding.cryptocurrency.symbol.uppercased())
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("$\(holding.valueUSD, specifier: "%.2f")")
                    .font(.headline)
                Text("\(holding.amount, specifier: "%.4f") \(holding.cryptocurrency.symbol.uppercased())")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
    }
}


#Preview(body: {
    DashboardView()
})

