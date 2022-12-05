//
//  LogEntry.swift
//  CmTraceParser
//
//  Created by Markus Bux on 01.12.22.
//

import Foundation

public struct LogEntry {
    public enum Severity:Int {
        case Unknown = 0
        case Information
        case Warning
        case Error
    }
    
    init(_ message:String,
         threadId:Int?,
         timestamp:Date?,
         component:String?,
         logLevel level:Severity,
         logFile file:String? = nil,
         context:String? = nil) {
        self.message = message
        self.timestamp = timestamp ?? Date(timeIntervalSince1970: 0)
        self.threadId = threadId
        self.component = component
        self.logLevel = level
        self.context = context
        self.file = file
    }
    
    init(_ message: String) {
        self.init(message,
                  threadId: 0,
                  timestamp: nil,
                  component: nil,
                  logLevel: .Information
        )
    }
    
    init(_ message: String.SubSequence) {
        self.init(String(message),
                  threadId: 0,
                  timestamp: nil,
                  component: nil,
                  logLevel: .Information
        )
    }
    
    public var timestamp:Date
    public var threadId:Int?
    public var message:String
    public var component:String?
    public var logLevel:Severity
    public var file:String?
    public var context:String?
    
}
