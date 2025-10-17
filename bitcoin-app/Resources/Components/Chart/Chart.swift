//
//  ChartView.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 13/10/25.
//

import SwiftUI
import Charts

struct SiteView: Identifiable, Equatable {
    var id = UUID().uuidString
    var date: Date
    var values: Double
    var animate: Bool = false
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

struct ChartView: View {
    @State var chartData: [SiteView]
    @Binding var currentTap: String
    @State private var currentActive: SiteView?
    @State private var plotWidth: CGFloat = 0
    @State private var selectedItem: Date?
    
    @State var displayLineChart: Bool = true
    @State var displayRuleMark: Bool = false
    
    var selectedDateView: SiteView? {
        guard let selectedItem else { return nil }
        return chartData.first {
            Calendar.current.isDate(selectedItem, equalTo: $0.date, toGranularity: .month)
        }
    }
    
    var currentValue: String {
        if let selectedDateView {
            return String(selectedDateView.values)
        }
        
        return "1.2500"
    }
    
    var body: some View {
        
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Total worth")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .bold()
                    
                    Text(currentValue)
                        .font(.title)
                        .bold()
                }
                Spacer()
            }
            LineChart()
            
            header
            Spacer()
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.white)
        }
        .chartXSelection(value: $selectedItem)
        .frame(height: 300)
        
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Picker("", selection: $currentTap) {
                    Text("7 week").tag("7 week")
                    Text("1 month").tag("1 month")
                    Text("1 year").tag("1 year")
                }
                .pickerStyle(.segmented)
                .padding(.top)
            }
        }
    }
    
    @ViewBuilder
    func LineChart() -> some View {
        let maxViews = chartData.max(by: { $0.values < $1.values })?.values ?? 0
        
        Chart {
            ForEach(chartData) { item in
                if displayLineChart {
                    LineMark(x: .value("hour", item.date, unit: .month), y: .value("Views", item.animate ? item.values : 0))
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Color.green.gradient)
                    
                    
                    AreaMark(x: .value("hour", item.date, unit: .month), y: .value("Views", item.animate ? item.values : 0))
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Color.green.opacity(0.06).gradient)
                } else {
                    BarMark(x: .value("hour", item.date, unit: .month), y: .value("Views", item.animate ? item.values : 0))
                        .foregroundStyle(Color.green.gradient)
                    
                    
                    
                }
                
            }
            
            if let selectedDateView {
                RuleMark(x: .value("Selected Month", selectedDateView.date, unit: .month))
                    .annotation(position: .top, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                        if displayRuleMark {
                            let value = "\(selectedDateView.values)"
                            VStack {
                                Text(selectedDateView.date, format: .dateTime.month(.wide) )
                                    .bold()
                                
                                Text(value)
                                    .bold()
                                
                            }
                            .foregroundColor(.white)
                            .padding(12)
                            .frame(width: 120)
                            .background(RoundedRectangle(cornerRadius: 10).fill(.blue.gradient))
                        }
                    }
            }
        }
        .chartYScale(domain: 0...(maxViews + 1000))
        .onAppear {
            animateGraph()
        }
        .chartXSelection(value: $selectedItem)
    }
    
    func updateChartData(for newValue: String) {
        chartData = sampleData
        
        if newValue != "1 week" {
            for index in chartData.indices {
                chartData[index].values = Double.random(in: 1500...10000)
            }
        }
        
        animateGraph(fromChange: true)
    }
    
    private func animateGraph(fromChange: Bool = false) {
        for (index, _) in chartData.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * (fromChange ? 0.02 : 0.05)) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    chartData[index].animate = true
                }
            }
        }
    }
}


#Preview {
    ChartView(
        chartData: sampleData,
        currentTap: .constant("7 Days")
    )
}
