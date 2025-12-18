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
        ScrollView {
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
            .task { viewModel.loadValues() }
            .onChange(of: viewModel.selectedFilter) { oldValue, newValue in
                viewModel.filterData(by: newValue)
            }
            .onChange(of: viewModel.dashboardListSelected) { _, value in
                withAnimation(.spring) {
                    viewModel.filterList(by: value)
                }
            }
        }
        .scrollIndicators(.hidden)
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
            
            VStack {
                HStack {
                    
                    Text("\(viewModel.dashboardListSelected)".localized)
                        .bold()
                    
                    Spacer()
                    
                    Picker("", selection: $viewModel.dashboardListSelected) {
                        Text("wallet".localized).tag("wallet")
                        Text("watch_list".localized).tag("watch_list")
                        Text("trending".localized).tag("trending")
                    }
                    .pickerStyle(.automatic)
                }
                .padding(.horizontal)
                
                ForEach(viewModel.filteredList) { transaction in
                    NavigationLink {
                        DestinationView(transaction: transaction)
                    } label: {
                        TransactionCard(transaction: transaction)
                            .listRowInsets(EdgeInsets())
                            .padding(.vertical, 2)
                            .padding(.horizontal, 5)
                    }
                }
            }
            
            Spacer()
        }
    }
}

struct Icon: Identifiable {
    var id: String
    var color: Color
}

struct DestinationView: View {
    var transaction: Transaction
    
    var body: some View {
        VStack {
            Image(transaction.image)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(.rect(cornerRadius: 12))
            
            Text(transaction.name)
        }
        .navigationTitle(transaction.name)
    }
}
