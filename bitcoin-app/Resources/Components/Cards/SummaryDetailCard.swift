//
//  SummaryDetailCard.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 13/12/25.
//

import SwiftUI

struct SummaryDetailCard: View {
    let title: String, value: String, percentageChange: String, iconName: String, color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack { Image(systemName: iconName).foregroundColor(color).font(.title2); Text(title).font(.subheadline).foregroundColor(ColorPalette.secondary200) }
            Text(value).font(.title2).fontWeight(.bold).foregroundColor(ColorPalette.textColor)
            Text(percentageChange).font(.caption).fontWeight(.medium).foregroundColor(percentageChange.contains("-") ? ColorPalette.red : ColorPalette.green)
        }.padding().frame(maxWidth: .infinity, alignment: .leading).background(ColorPalette.backgroundView200).cornerRadius(15).shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
