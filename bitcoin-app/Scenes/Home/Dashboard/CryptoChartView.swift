import SwiftUI
import Charts

struct PricePoint: Identifiable {
    let id = UUID()
    let date: Date
    let price: Double
}

struct CryptoChartView: View {
    var priceHistory: [PricePoint]
    var cryptocurrencyName: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Gráfico de Preço - \(cryptocurrencyName)")
                .font(.headline)
                .padding(.bottom, 5)
            
            Chart {
                ForEach(priceHistory) {
                    LineMark(
                        x: .value("Data", $0.date),
                        y: .value("Preço", $0.price)
                    )
                    .foregroundStyle(.green)
                }
            }
            .chartYAxis(.hidden)
            .chartXAxis(.hidden)
            .frame(height: 150)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

#Preview {
    let samplePriceHistory: [PricePoint] = [
        PricePoint(date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, price: 58000),
        PricePoint(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, price: 59000),
        PricePoint(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, price: 58500),
        PricePoint(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, price: 60000),
        PricePoint(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, price: 61000),
        PricePoint(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, price: 60500),
        PricePoint(date: Date(), price: 62000)
    ]
    return CryptoChartView(priceHistory: samplePriceHistory, cryptocurrencyName: "Bitcoin")
}
