//
//  SectionsCards.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 22/10/25.
//

import SwiftUI
import Foundation

extension SettingsView {
    @ViewBuilder
    func sectionsCards(item: OptionModel) -> some View {
        HStack {
            Image(systemName: item.icon)
                .foregroundColor(Color(item.color))
                .frame(width: 28)
                .opacity(item.enabled ? 1 : 0.3)
            
            switch item.type {
            case .toggle:
                Toggle(isOn: viewModel.setBinding(for: item.id)) {
                    Text(item.title.localized)
                        .foregroundColor(item.enabled ? .light : .disabled)
                }
                .disabled(!item.enabled)
            case .picker:
                if let pickerOptions = item.options {
                    Picker("\(item.title)".localized, selection: viewModel.pickerBinding(for: item.id)) {
                        ForEach(pickerOptions, id: \.tag) { option in
                            Text("\(option.title)".localized).tag(option.tag)
                        }
                    }
                    .disabled(!item.enabled)
                }
                
            case .navigation:
                NavigationLink(destination: getDestinationView(view: item)) {
                    Text("\(item.title)".localized)
                }.disabled(!item.enabled)
                
            default:
                EmptyView()
            }
        }
    }

    func getDestinationView(view: OptionModel) -> some View {
        switch view.id {
        case "contact":
            return AnyView(ContactView())
            
        case "about_app":
            return AnyView(AboutView())
            
        default:
            return AnyView(EmptyView())
        }
    }
}
