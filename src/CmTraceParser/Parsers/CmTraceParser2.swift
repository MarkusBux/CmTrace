//
//  CmTraceParser2.swift
//  CmTraceParser
//
//  Created by Markus Bux on 02.12.22.
//

import Foundation
public class CmTraceParser2: LogFileParser{
   
    let checkPattern = /\s{1,2}\$\$\<.*\>/.ignoresCase()
    let pattern = /^(?<Message>.*)\s{1,2}\$\$\<(?<Component>.*?)\><(?<Timestamp>.*?)(?<Offset>[-+]\d{1,3})\><thread=(?<TID>\d+).*\>/.ignoresCase().dotMatchesNewlines()
    
   
    public init(){}
    
    public func canParse(_ content: String) -> Bool {
        let c1 = String(content.lines[0])
        let c2 = String(content.lines[1])
        let c3 = String(content.lines[2])
        if let _ = c1.firstMatch(of: checkPattern) {
            return true
        }
        if let _ = c2.firstMatch(of: checkPattern) {
            return true
        }
        if let _ = c3.firstMatch(of: checkPattern) {
            return true
        }
        return false
    }
    
    
    public func parse(_ content: String) async -> [LogEntry] {
        return await doParse(content)
    }
    
    private func doParse(_ content: String) async -> [LogEntry] {
        async let getLineTask = Task {
            return getSingleRawEntries(content)
        }
        
        let lines = await getLineTask.value
        
        var entries = [LogEntry]()
        for line in lines {
            entries.append(parseLineEntry(line))
        }
        
        return entries
    }
    
    private func parseLineEntry(_ line: String.SubSequence) -> LogEntry {
        let l = String(line)
        if let match = l.firstMatch(of: pattern) {
            let message = match.output.Message
            let threadId = Int(match.output.TID) ?? 0
            let type = LogEntry.Severity.Information
            let component = match.output.Component
            var timestamp:Date? = nil
            
            if let dt = "\(match.output.Timestamp)".toDate(dateFormat: "MM-dd-yyyy HH:mm:ss.SSS", minuteOffsetToUtc: Int(match.output.Offset) ?? 0) {
                timestamp = dt
            }
            
            return LogEntry(String(message), threadId: threadId, timestamp: timestamp, component: String(component), logLevel: type)
        }
        
        return LogEntry(line)
    }
    
    private func getSingleRawEntries(_ content: String) -> [String.SubSequence] {
        let lines:[String.SubSequence] = content.lines
               
        return lines
    }
}
