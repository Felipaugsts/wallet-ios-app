//
//  TransactionCard.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 20/10/25.
//

import SwiftUI

struct Transaction: Identifiable {
    var id = UUID().uuidString
    var name: String
    var type: String
    var value: String
    var image: String
    var dayChangePorcentage: String
}

struct TransactionCard: View {
    var transaction: Transaction
    
    var body: some View {
        HStack {
            Image(transaction.image)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(transaction.name)
                    .font(.headline)
                    .foregroundColor(ColorPalette.secondary100)
                
                Text(transaction.type)
                    .font(.subheadline)
                    .foregroundColor(ColorPalette.secondary200)
            }
            
            Spacer()
            
            Text(transaction.value)
                .font(.headline)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(ColorPalette.backgroundView)
        }
    }
}

