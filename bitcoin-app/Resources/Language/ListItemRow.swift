//
//  ListItemRow.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 13/12/25.
//

import SwiftUI

struct ListItemRow<TrailingContent: View>: View {
    let iconName: String, iconColor: Color, title: String, subtitle: String?, trailingTopText: String, trailingTopColor: Color
    let trailingBottomContent: TrailingContent

    init(iconName: String, iconColor: Color, title: String, subtitle: String?, trailingTopText: String, trailingTopColor: Color, @ViewBuilder trailingBottomContent: () -> TrailingContent) {
        self.iconName = iconName; self.iconColor = iconColor; self.title = title; self.subtitle = subtitle; self.trailingTopText = trailingTopText; self.trailingTopColor = trailingTopColor; self.trailingBottomContent = trailingBottomContent()
    }

    init(iconName: String, iconColor: Color, title: String, subtitle: String?, trailingTopText: String, trailingTopColor: Color) where TrailingContent == EmptyView {
        self.init(iconName: iconName, iconColor: iconColor, title: title, subtitle: subtitle, trailingTopText: trailingTopText, trailingTopColor: trailingTopColor, trailingBottomContent: { EmptyView() })
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            Image(systemName: iconName).font(.title2).foregroundColor(iconColor).frame(width: 30)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).fontWeight(.medium).foregroundColor(ColorPalette.textColor)
                if let subtitle = subtitle { Text(subtitle).font(.caption).foregroundColor(ColorPalette.secondary200) }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(trailingTopText).fontWeight(.semibold).foregroundColor(trailingTopColor)
                trailingBottomContent
            }
        }.padding(.vertical, 12).padding(.horizontal)
    }
}
