//
//  TransactionDetails.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 02/01/26.
//

import SwiftUI

struct TransactionDetails: View {
    var body: some View {
        VStack {
            Text("Total R$ 320")
                .font(.headline)
            
            Text("R$ 320")
                .font(.title)
            
            Text("Total R$ 320")
                .font(.footnote)
            
            ProgressView()
                .progressViewStyle(LinearProgressViewStyle())
                .frame(width: 250, height: 10)
            
            Text("4% da sua renda mensal")
                .font(.footnote)
        }
    }
}

#Preview {
    TransactionDetails()
}
