//
//  StringProtocol.swift
//  CmTraceParser
//
//  Created by Markus Bux on 01.12.22.
//

import Foundation

extension StringProtocol {

    /// Returns the first index of the specified value appears in the collection.
    /// - Parameters:
    ///   - value: value to search
    ///   - options: comparition options
    /// - Returns: The index of the first `char` within the `value`
    func firstIndex<T: StringProtocol>(of value: T, options: String.CompareOptions = []) -> Index? {
        range(of: value, options: options)?.lowerBound
    }
    
    /// Returns the last index of the specified value appears in the collection.
    /// - Parameters:
    ///   - value: value to search
    ///   - options: comparition options
    /// - Returns: The index of the first `char` of the last occurance within the `value`
    func endIndex<T: StringProtocol>(of value: T, options: String.CompareOptions = []) -> Index? {
        range(of: value, options: options)?.upperBound
    }
    
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        ranges(of: string, options: options).map(\.lowerBound)
    }
    
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
              let range = self[startIndex...]
                .range(of: string, options: options) {
            result.append(range)
            startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
    
    /// Return the content splittet by `Character.isNewLine`
    var lines: [SubSequence] { split(whereSeparator: \.isNewline) }
    
    /// Try to convert the `string` to the a `Date` instance
    public func toDate(dateFormat: String, timeZone: TimeZone) -> Date? {
        let dtFormater = DateFormatter()
        dtFormater.locale = Locale.current
        dtFormater.calendar = Calendar.current
        dtFormater.timeZone = timeZone
        dtFormater.dateFormat = dateFormat
        
        return dtFormater.date(from: String(self))
    }
    
    public func toDate(dateFormat: String) -> Date? {
        self.toDate(dateFormat: dateFormat, timeZone: TimeZone.current)
    }
    
    public func toDate(dateFormat: String, minuteOffsetToUtc offset: Int) -> Date? {
        let offsetCalc = offset * 60 * -1
        if let tz = TimeZone(secondsFromGMT: offsetCalc)
        {
                return self.toDate(dateFormat: dateFormat, timeZone: tz)
        }
        
        return self.toDate(dateFormat: dateFormat, timeZone: TimeZone.current)
    }
}

extension Array where Element : StringProtocol {
    /// Appends the value to the array in case it is not empty
    ///
    /// - parameter value: The value to append
    /// - returns: `true` if appended, otherwise `false`
    mutating func appendIfNotEmpty(_ value: Element) {
        guard !value.isEmpty else { return }
        append(value)
    }    
}
