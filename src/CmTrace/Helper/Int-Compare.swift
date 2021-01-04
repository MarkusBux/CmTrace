//
//  Int-Compare.swift
//  CmTrace2
//
//  Created by Markus Bux on 16.12.20.
//

import Foundation

extension Int {
    func compare(_ other:Int) -> ComparisonResult {
        self < other ? .orderedAscending : .orderedDescending
    }
    
    var formattedWithSeparator: String {Formatter.withSeparator.string(for: self) ?? ""}
}

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        return formatter
    }()
}
