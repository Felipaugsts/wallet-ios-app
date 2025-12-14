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

struct ChartView: View {
    @Binding var chartData: [SiteView]
    @Binding var currentTap: String
    @State private var currentActive: SiteView?
    @State private var plotWidth: CGFloat = 0
    @State private var selectedItem: Date?
    
    @State var displayLineChart: Bool = false
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
                        .foregroundColor(ColorPalette.secondary100)
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
                .fill(ColorPalette.backgroundView)
        }
        .chartXSelection(value: $selectedItem)
        .frame(height: 300)
        
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Picker("", selection: $currentTap) {
                    Text("seven_days".localized).tag("seven_days")
                    Text("one_month".localized).tag("one_month")
                    Text("one_year".localized).tag("one_year")
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
                        .interpolationMethod(.cardinal)
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
        .onChange(of: chartData, { oldValue, newValue in
            animateGraph()
        })
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
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * (fromChange ? 0.02 : 0.02)) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    chartData[index].animate = true
                }
            }
        }
    }
}


//#Preview {
//    ChartView(
//        chartData: sampleData,
//        currentTap: .constant("7 Days")
//    )
//}
