//
//  CmLogItems.swift
//  CmTrace2
//
//  Created by Markus Bux on 16.12.20.
//

import Foundation
import Combine
import os
import CmTraceParser

class CmLogItems {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "\(CmLogItems.self)")
    
    private let loader = CmLogFileLoader.Default
    private var logItems:[URL:[LogItem]] {
        didSet {
            logger.debug("Setting value for internal logItems.")
            self.entries = logItems.values.flatMap({$0})
            self.loadedFiles = logItems.keys.map({$0})
            self.totalEntriesCount = self.entries.count
            logger.debug("Loaded '\(self.totalEntriesCount)' entries in total")
        }
    }
    
    init() {
        logItems = [:]
        entries = []
        loadedFiles = []
        totalEntriesCount = 0
    }
    
    // MARK: - Data Access
    /// The currenlty loaded or filtered entries.
    fileprivate (set) var entries:[LogItem]
    
    /// Count of all loaded log entries regardless of some filters
    private (set) var totalEntriesCount:Int
    
    var hasLoadedData: Bool { loadedFiles.count > 0 }
    
    /// Array of files used to load the entries
    private (set) var loadedFiles:[URL]
    
    
    typealias onFileProcessedCallback = (URL) -> Void
    
    // MARK: - Intents
    /// Load all items from the requested files asynchronously
    func loadFileEntries(for files:[URL], onFileProcessed: onFileProcessedCallback? = nil)  async {
        
        var result:[URL: [LogItem]] = [:]
        
        let res = await withTaskGroup(of: (URL, [LogEntry]).self) { group in
            for file in files {
                group.addTask(priority: TaskPriority.userInitiated) {
                    do {
                        let entries = try await self.loader.ParseFile(file)
                        self.logger.debug("Retrieved '\(entries.count)' entries from file '\(file)'")
                        return(file, entries)
                    }
                    catch {
                        self.logger.error("Error while parsing file '\(file, privacy: .public)'. \(error.localizedDescription, privacy: .public)")
                        return (file, [])
                    }
                }
            }

            var entries:[URL:[LogItem]] = [:]
            
            for await (fileUrl, fileEntries) in group {
                let logItems = fileEntries.compactMap( {item in
                    LogItem(cmLogItem: item)
                })
                
                entries[fileUrl] = logItems
                onFileProcessed?(fileUrl)
            }
            
            return entries
        }


        for data in res {
            result[data.key] = data.value
        }
        self.logItems = result
    }
    
    /// Filter the loaded entries by the given string
    ///
    /// - parameter searchString: string to search for within the message
    func search(searchString value:String?){
        if value == nil || value!.isEmpty {
            self.entries = logItems.values.flatMap({$0})
        }
        else {
            let items = logItems.values.flatMap({$0})
            
            entries = items.filter({ (item) -> Bool in
                if let _ = item.message.range(of: value!, options: [.caseInsensitive]) { return true }
                else { return false }
            })
            
        }
    }
    
    /// Sort the loaded / filtered entries
    func sort(by key:String , asc directionIsAsc:Bool) {
        let co = directionIsAsc ? ComparisonResult.orderedAscending : ComparisonResult.orderedDescending
        switch key {
            case "message":
                entries.sort  {(lhs, rhs) -> Bool in
                    return lhs.message.localizedCaseInsensitiveCompare(rhs.message) == co
                }
            case "component":
                entries.sort(by: { (lhs, rhs) -> Bool in
                    guard let lhsComponente = lhs.component else { return directionIsAsc}
                    guard let rhsComponent = rhs.component else { return !directionIsAsc}
                    return lhsComponente.localizedCaseInsensitiveCompare(rhsComponent) == co
                })
            case "timestamp":
                entries.sort(by: { (lhs, rhs) -> Bool in
                    return lhs.timestamp.compare(rhs.timestamp) == co
                })
            case "correlationId":
                entries.sort(by: { (lhs, rhs) -> Bool in
                    guard let lhsOperationId = lhs.operationId else { return directionIsAsc}
                    guard let rhsOperationId = rhs.operationId else { return !directionIsAsc}
                    
                    guard let lhsInt = Int(lhsOperationId) else { return directionIsAsc }
                    guard let rhsInt = Int(rhsOperationId) else { return !directionIsAsc }
                    
                    return lhsInt.compare(rhsInt) == co
                })
            default:
                break;
        }
    }
}

// MARK: - "Casting" Initializer
extension LogItem {
    convenience init(cmLogItem item: LogEntry) {
        self.init(item.message, timestamp: item.timestamp)
        
        self.operationId = String(item.threadId ?? -1)
        self.component = item.component
        self.logLevel = LogItem.LogLevel(rawValue: item.logLevel.rawValue) ?? LogItem.LogLevel.Unknown
        self.source = item.file
    }
}
