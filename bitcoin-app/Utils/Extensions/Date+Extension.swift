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
}
