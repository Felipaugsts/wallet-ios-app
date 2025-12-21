//
//  ListItemRow.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 13/12/25.
//

import SwiftUI

struct ListItemRow: View {
    let iconName: String
    let iconColor: Color
    let title: String
    let subtitle: String?
    let trailingTopText: String
    let trailingTopColor: Color
    let percentage: Double
    let value: Double

    init(iconName: String, iconColor: Color, title: String, subtitle: String?, trailingTopText: String, trailingTopColor: Color, percentage: Double, value: Double) {
        self.iconName = iconName
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.trailingTopText = trailingTopText
        self.trailingTopColor = trailingTopColor
        self.percentage = percentage
        self.value = value
    }

    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 15) {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(iconColor)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .fontWeight(.medium)
                        .foregroundColor(ColorPalette.textColor)
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(ColorPalette.secondary200)
                    }
                    Text("\(percentage) %")
                        .font(.subheadline)
                        .foregroundColor(ColorPalette.secondary200)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(trailingTopText)
                        .fontWeight(.semibold)
                        .foregroundColor(trailingTopColor)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal)
            
            ProgressView(value: percentage, total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: trailingTopColor))
                .scaleEffect(x: 1, y: 3, anchor: .center)
        }
        .background(ColorPalette.backgroundView200)
        .cornerRadius(8)
        .shadow(radius: 4)
    }
}
