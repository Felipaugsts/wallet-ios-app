//
//  Date+Extension.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 13/12/25.
//
import Foundation
import SwiftUI

extension Date {
    static func from(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents(); components.year = year; components.month = month; components.day = day; return Calendar.current.date(from: components)!
    }
    
    func isSameMonthAndYear(as other: Date) -> Bool {
          let calendar = Calendar.current
          
          // Extrai os componentes de ano e mês
          let components1 = calendar.dateComponents([.year, .month], from: self)
          let components2 = calendar.dateComponents([.year, .month], from: other)
          
          // Compara o ano e o mês
          return components1.year == components2.year && components1.month == components2.month
      }
}
