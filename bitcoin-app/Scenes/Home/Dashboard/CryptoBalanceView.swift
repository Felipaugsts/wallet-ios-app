import SwiftUI

struct CryptoBalanceView: View {
    var totalBalance: Double
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Saldo Total da Carteira")
                .font(.headline)
                .foregroundColor(.gray)
            Text("$\(totalBalance, specifier: "%.2f")")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

#Preview {
    CryptoBalanceView(totalBalance: 12345.67)
}
