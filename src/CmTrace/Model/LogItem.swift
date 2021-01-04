//
//  LogEntry.swift
//  CmTrace
//
//  Created by Markus Bux on 08.12.20.
//

import Foundation


class LogItem:NSObject {
    init(_ message:String, timestamp:Date, logLevel:LogLevel = .Unknown, component:String? = nil, operationId:String? = nil, source:String? = nil) {
        self.message = message
        self.timestamp = timestamp
        self.operationId = operationId
        self.component = component
        self.logLevel = logLevel
        self.source = source
    }
    
    
    @objc dynamic var timestamp:Date
    @objc dynamic var operationId:String?
    @objc dynamic var message:String
    @objc dynamic var component:String?
    @objc dynamic var logLevel:LogLevel
    @objc dynamic var source:String?


    @objc enum LogLevel:Int {
        case Unknown = 0
        case Information
        case Warning
        case Error
    }

}
