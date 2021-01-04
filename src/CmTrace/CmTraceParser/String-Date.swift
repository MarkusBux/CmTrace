//
//  String-Date.swift
//  CmTrace
//
//  Created by Markus Bux on 08.12.20.
//

import Foundation

extension String {
    
    func toDate(format:String) -> Date?{
        let dtFormater = DateFormatter()
        dtFormater.locale = Locale.current
        dtFormater.calendar = Calendar.current
        dtFormater.timeZone = TimeZone.current
        dtFormater.dateFormat = format
        
        return dtFormater.date(from: self)
    }
}
