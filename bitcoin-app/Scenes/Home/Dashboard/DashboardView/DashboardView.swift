//
//  ExpensesCard.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 13/12/25.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State var displayDetails = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 13) {
                HeaderView(month: viewModel.monthFormatter.string(from: viewModel.currentDate))
                    .shimmer(when: $viewModel.isLoading)
                
                MainSummaryCard(overview: viewModel.overView)
                    .shimmer(when: $viewModel.isLoading)
                
                DetailedSummaryView()
                    .shimmer(when: $viewModel.isLoading)
                
                summaryCard
                
                VStack {}
                    .frame(height: 50)
                    .background(Color(uiColor: .systemGroupedBackground))
            }
            .padding()
        }
        .task {
            viewModel.filterBy = ""
            viewModel.fetchSummary()
        }
        .navigationBarTitleDisplayMode(.large)
        .background(Color(uiColor: .systemGroupedBackground))
        .scrollIndicators(.hidden)
        .environmentObject(viewModel)
        .navigationDestination(isPresented: $displayDetails) {
            SubscriptionManagerView(preSelectedTransactionType: .expense)
                .environmentObject(viewModel)
        }
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
    
    private var summaryCard: some View {
        Group {
            if !viewModel.expenseSummary.isEmpty {
                VStack(spacing: 16) {
                    ForEach(viewModel.expenseSummary) { data in
                        FinancialSummaryCard(data: data) { filter in
                            displayDetails = true
                            viewModel.filterBy = filter
                        }
                    }
                }
            } else if viewModel.isLoading {
                FinancialSummaryCard(data: .loadingStateValues, onTapItem: { _ in })
                .shimmer(when: $viewModel.isLoading)
            } else {
                Text("Nenhum resumo disponível.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
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
