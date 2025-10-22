//
//  FixedSections.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 22/10/25.
//

import SwiftUI

extension SettingsView {
    @ViewBuilder
    func fixedSections() -> some View {
        Section {
            Button(action: {
            }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.red)
                        .frame(width: 28)
                    Text("Sair")
                        .foregroundColor(.red)
                }
            }
        }
        
        Section {
            HStack {
                Spacer()
                VStack(spacing: 4) {
                    Text("Finanças Pessoais")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Versão 1.0.0")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
}
