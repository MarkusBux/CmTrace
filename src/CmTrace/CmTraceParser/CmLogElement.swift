//
//  CmLogItem.swift
//  CmTrace
//
//  Created by Markus Bux on 24.11.20.
//

import Foundation

struct CmLogElement {
    enum CmLogType:Int {
        case Unknown = 0
        case Information
        case Warning
        case Error
    }
    
    init(_ message:String,
         threadId:Int? = nil,
         timestamp:Date,
         component:String? = nil,
         logLevel level:CmLogType = CmLogType.Unknown,
         logFile file:String? = nil,
         context:String? = nil
    ) {
        self.message = message
        self.timestamp = timestamp
        self.threadId = threadId
        self.component = component
        self.logLevel = level
        self.context = context
        self.file = file
    }
    
    public var timestamp:Date
    public var threadId:Int?
    public var message:String
    public var component:String?
    public var logLevel:CmLogType
    public var file:String?
    public var context:String?
    
}
