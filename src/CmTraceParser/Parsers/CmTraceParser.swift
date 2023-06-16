//
//  CmTraceParser.swift
//  CmTraceParser
//
//  Created by Markus Bux on 01.12.22.
//

import Foundation

public class CmTraceParser: LogFileParser{
   
    
    let pattern = /\<\!\[LOG\[(?<Message>.*)?\]LOG\]\!\>\<time=\"(?<Time>.+?)?\"\s+date=\"(?<Date>.+?)?\"\s+component=\"(?<Component>.+?)?\"\s+context=\"(?<Context>.*?)?\"\s+type=\"(?<Type>\d)?\"\s+thread=\"(?<TID>\d+)?\"\s+file=\"(?<Reference>.*)?\"\>/.ignoresCase().dotMatchesNewlines()
    let logStartToken = "<![LOG["
    let logEndToken = "]LOG]!>"
    
   
    public init(){}
    
    public func canParse(_ content: String) -> Bool {
        let logStartIndex = content.firstIndex(of: logStartToken)
        let logEndIndex = content.firstIndex(of: logEndToken)
        
        if logStartIndex == nil && logEndIndex == nil {
            return false
        }
        
        return true
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
            let message = match.output.Message ?? ""
            let threadId = Int(match.output.TID!) ?? 0
            let type = LogEntry.Severity(rawValue: Int(match.output.Type!) ?? 0) ?? LogEntry.Severity.Unknown
            let component = match.output.Component!
            let context = match.output.Context!
            let file = match.output.Reference!
            
            var timestamp:Date? = nil
            if let dt = "\(match.output.Date ?? "") \(match.output.Time ?? "")".toDate(dateFormat: "MM-dd-yyyy HH:mm:ss.SSSSSSS") {
                timestamp = dt
            }
            
            return LogEntry(String(message), threadId: threadId, timestamp: timestamp, component: String(component), logLevel: type, logFile: String(file),context: String(context))
        }
        
        return LogEntry(l)
    }
    
    private func getSingleRawEntries(_ content: String) -> [String.SubSequence] {
        var lines:[String.SubSequence] = []
        
        let rawLines = content.lines
        var currentLine:String.SubSequence = ""
        let zeroBasedContentCount = content.count - 1
        
        for (idx, rawLine) in rawLines.enumerated() {
            // Check if this is the start of a new entry
            if let index = rawLine.firstIndex(of: logStartToken) {
                // If index == startIndex
                // 1. add current line to result
                // 2. reset current line to new log entry start value
                // Otherwise split at index and
                // 1. add first part of split to previous entry
                // 2. Append previous entry to the result
                // 3. reset current line to new log entry start value
                
                if index == rawLine.startIndex {
                    lines.appendIfNotEmpty(currentLine)
                    
                    // Start over with a new log entry
                    currentLine = rawLine
                } else {
                    // Split the rawLine
                    let previousEntry = rawLine[..<index]
                    let newEntry = rawLine[index...]
                    
                    currentLine = currentLine.isEmpty ? previousEntry : "\(currentLine)\n\(previousEntry)"
                    lines.appendIfNotEmpty(currentLine)
                    currentLine = newEntry
                }
                
                
            } else {
                // This is an additiona line for an existing entry
                // as no `logStartToken` was found
                currentLine = currentLine.isEmpty ? rawLine : "\(currentLine)\n\(rawLine)"
            }
            
            // if it is the last line of the content, we need to append it
            if idx == zeroBasedContentCount {
                lines.appendIfNotEmpty(currentLine)
            }
        }
        
        return lines
    }
}
