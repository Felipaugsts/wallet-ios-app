//
//  StockWalletDashboard.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 20/10/25.
//

import SwiftUI

struct StockWalletView: View {
    
    @StateObject var viewModel = StockWalletViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                    switch viewModel.viewState {
                    case .loading:
                        ProgressView()
                        
                    case .failure:
                        ContentUnavailableView(LocalizedStringKey(stringLiteral: "Something went wrong"), systemImage: "")
                        
                    case .loaded:
                        dashboard()
                    }
            }
            .background(ColorPalette.backgroundView)
            .task {
                viewModel.loadValues()
            }
            .onChange(of: viewModel.selectedFilter) { oldValue, newValue in
                viewModel.filterData(by: newValue)
            }
        }
    }
}
extension StockWalletView {
    
    @ViewBuilder
    func dashboard() -> some View {
        VStack {
            ChartView(
                chartData: $viewModel.filteredData,
                currentTap: $viewModel.selectedFilter
            )
            
            Section(
                header:
                    Text("transactions".localized)
                    .font(.headline)
                    .foregroundColor(ColorPalette.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)) {
                        List(viewModel.transactions) { transaction in
                            TransactionCard(transaction: transaction)
                                .listRowInsets(EdgeInsets())
                                .padding(.vertical, 10)
                                .padding(.horizontal, 5)
                        }
                        .listStyle(.plain)
                        .background(Color.clear)
                    }
                    .background(ColorPalette.backgroundView)
            
            Spacer()
        }
    }
}
