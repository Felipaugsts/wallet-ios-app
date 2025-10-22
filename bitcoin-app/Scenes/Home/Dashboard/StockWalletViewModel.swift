//
//  StockWalletViewModel.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 21/10/25.
//

import SwiftUI

class StockWalletViewModel: ObservableObject {

    @Published var selectedFilter: String = "seven_days"
    @Published var viewState: ViewState = .loading
    @Published var filteredData: [SiteView] = []
    @Published var transactions: [Transaction] = []
    
    private var loadedData: [SiteView] = []
    
    func loadValues() {
        
        transactions = [
            Transaction(name: "Bitcoin", type: "Buy", value: "$10,000", image: "bitcoin_logo"),
            Transaction(name: "Ethereum", type: "Sell", value: "$2,500", image: "ethereum_logo"),
            Transaction(name: "Litecoin", type: "Buy", value: "$300", image: "bitcoin_logo"),
            Transaction(name: "Ripple", type: "Sell", value: "$150", image: "bitcoin_logo"),
            Transaction(name: "Ripple", type: "Sell", value: "$150", image: "bitcoin_logo"),
            Transaction(name: "Ripple", type: "Sell", value: "$150", image: "bitcoin_logo"),
            Transaction(name: "Ripple", type: "Sell", value: "$150", image: "bitcoin_logo"),
        ]
        loadedData = sampleData
        filterData(by: "seven_days")
        
        viewState = .loaded
    }
    
    func filterData(by timeFrame: String) {
        var filteredData = loadedData
        
        if timeFrame != "seven_days" {
            for index in filteredData.indices {
                filteredData[index].values = Double.random(in: 1500...10000)
            }
        }
        
        self.filteredData = filteredData
    }
    
//    func filterData(by timeFrame: String) {
//        let currentDate = Date()
//        
//        switch timeFrame {
//        case "seven_days":
//            let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: currentDate)!
//            filteredData = loadedData.filter { $0.date >= sevenDaysAgo }
//            
//        case "one_month":
//            let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: currentDate)!
//            filteredData = loadedData.filter { $0.date >= oneMonthAgo }
//            
//        case "one_year":
//            let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: currentDate)!
//            filteredData = loadedData.filter { $0.date >= oneYearAgo }
//            
//        default:
//            print("Período inválido. Utilize '7 dias', '1 mês' ou '1 ano'.")
//        }
//    }
}


var sampleData: [SiteView] = [
    SiteView(date: Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 15, hour: 9))!, values: 150.0),
    SiteView(date: Calendar.current.date(from: DateComponents(year: 2025, month: 2, day: 10, hour: 10))!, values: 300.0),
    SiteView(date: Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 5, hour: 11))!, values: 78.5),
    SiteView(date: Calendar.current.date(from: DateComponents(year: 2025, month: 4, day: 20, hour: 12))!, values: 450.0, animate: true),
    SiteView(date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 25, hour: 13))!, values: 200.0),
    SiteView(date: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 15, hour: 14))!, values: 340.0, animate: true),
    SiteView(date: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 30, hour: 15))!, values: 600.0),
    SiteView(date: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 20, hour: 16))!, values: 720.0),
    SiteView(date: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 10, hour: 17))!, values: 310.0),
    SiteView(date: Calendar.current.date(from: DateComponents(year: 2025, month: 10, day: 5, hour: 18))!, values: 550.0)
]
