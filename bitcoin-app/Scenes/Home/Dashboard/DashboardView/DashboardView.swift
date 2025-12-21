//
//  ExpensesCard.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 13/12/25.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                HeaderView(month: viewModel.monthFormatter.string(from: viewModel.currentDate))
                    .shimmer(when: $viewModel.isLoading)
                
                MainSummaryCard(overview: viewModel.overView)
                    .shimmer(when: $viewModel.isLoading)
                
                DetailedSummaryView()
                    .shimmer(when: $viewModel.isLoading)
                
                investmentsSection
                    .shimmer(when: $viewModel.isLoading)
                
                VStack {}.frame(height: 50)
            }
            .padding()
        }
        .task { viewModel.fetchSummary() }
        .navigationBarTitleDisplayMode(.large)
        .background(Color(uiColor: .systemGroupedBackground))
        .scrollIndicators(.hidden)
        .environmentObject(viewModel)
    }
    
    // MARK: - Sections (ainda como computed properties para clareza)
    
    private var investmentsSection: some View {
        TitledSectionView(title: TextValue.investments.localized) {
            ListItemRow(
                iconName: "chart.pie.fill",
                iconColor: ColorPalette.orange,
                title: TextValue.totalInvested.localized,
                subtitle: "subtitle",
                trailingTopText: viewModel.formatCurrency(viewModel.overView?.totalInvestedValue ?? 0),
                trailingTopColor: ColorPalette.textColor,
                percentage: 35,
                value: viewModel.overView?.totalInvestedValue ?? 0
            )
            
            Divider().padding(.leading, 60)
        }
    }
    
    private func addNewItemView(action: @escaping () -> Void) -> some View {
        VStack(spacing: 3) {
            Image(systemName: "menubar.arrow.up.rectangle")
                .font(.body)
            
            Text("Click para adicionar um novo campo.")
                .font(.footnote)
        }
        .foregroundColor(.secondary)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(style: StrokeStyle(lineWidth: 1.2, dash: [6]))
                .foregroundColor(Color.secondary.opacity(0.2))
        )
        .opacity(0.5)
        .onTapGesture {
            action()
        }
    }
}

extension View {
    @ViewBuilder
    func shimmer(when isLoading: Binding<Bool>) -> some View {
        if isLoading.wrappedValue {
            self.modifier(Shimmer())
                .redacted(reason: isLoading.wrappedValue ? .placeholder : [])
        } else {
            self
        }
    }
}

public struct Shimmer: ViewModifier {
    @State private var isInitialState = true
    
    public func body(content: Content) -> some View {
        content
            .mask(
                LinearGradient(
                    gradient: .init(colors: [.black.opacity(0.4), .black, .black.opacity(0.4)]),
                    startPoint: (isInitialState ? .init(x: -0.3, y: -0.3) : .init(x: 1, y: 1)),
                    endPoint: (isInitialState ? .init(x: 0, y: 0) : .init(x: 1.3, y: 1.3))
                )
            )
            .animation(.linear(duration: 1.5).delay(0.25).repeatForever(autoreverses: false), value: isInitialState)
            .onAppear {
                isInitialState = false
            }
    }
}
