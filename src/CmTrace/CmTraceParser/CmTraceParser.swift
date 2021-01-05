import Foundation
import os



class CmTraceParser {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "\(CmTraceParser.self)")
    private let lock = NSLock()
    typealias CmLogType = CmLogElement.CmLogType
    
    private let regExDefault: NSRegularExpression
    private let regExAlternative: NSRegularExpression
    private let regExMsgOnly: NSRegularExpression
    
    init() {
        let defaultOptions: NSRegularExpression.Options = [.caseInsensitive, .anchorsMatchLines, .dotMatchesLineSeparators]
        let regExPatternDefault = #"\<\!\[LOG\[(?<Message>.*)?\]LOG\]\!\>\<time=\"(?<Time>.+)(?<TZAdjust>[+|-])(?<TZOffset>\d{2,3})\"\s+date=\"(?<Date>.+?)?\"\s+component=\"(?<Component>.+?)?\"\s+context=\"(?<Context>.*?)?\"\s+type=\"(?<Type>\d)?\"\s+thread=\"(?<TID>\d+)?\"\s+file=\"(?<Reference>.+?)?\"\>"#
        let regExPatternAlternative = #"\<\!\[LOG\[(?<Message>.*)?\]LOG\]\!\>\<time=\"(?<Time>.+?)?\"\s+date=\"(?<Date>.+?)?\"\s+component=\"(?<Component>.+?)?\"\s+context=\"(?<Context>.*?)?\"\s+type=\"(?<Type>\d)?\"\s+thread=\"(?<TID>\d+)?\"\s+file=\"(?<Reference>.+?)?\"\>"#
        let regExPatternMessageOnly = #"\<\!\[LOG\[(?<Message>.*)?\]LOG\]\!\>"#

        regExDefault = try! NSRegularExpression(pattern: regExPatternDefault, options: defaultOptions)
        regExAlternative = try! NSRegularExpression(pattern: regExPatternAlternative, options: defaultOptions)
        regExMsgOnly = try! NSRegularExpression(pattern: regExPatternMessageOnly, options: defaultOptions)
    }
    
    /// Parses all the files and returns the parsed log entries per file
    ///
    /// - parameter urls: The files to load and parse
    /// - parameter onParsingError:Optional closure to execute for each raw log entry that cannot be parsed
    ///
    /// - Returns: The parsed Configuration Manager log entries per file
    func parseFile (_ file:URL, onParsingError: ((Error, URL, String) -> Void)? = {_,_,_ in }) throws -> [CmLogElement]{
        var result:[CmLogElement] = []
        logger.debug("*** Start Processing '\(file, privacy: .public)' ***")
        guard let logLines = try readFileContent(from: file) else { return result }
        
        let _ = DispatchQueue.global(qos: .userInitiated)
        DispatchQueue.concurrentPerform(iterations: logLines.count) { (idx)  in
            let logLine = logLines[idx]
            do {
                if let item = try parseRawValue(for: logLine) {
                    lock.lock()
                    result.append(item)
                    lock.unlock()
                }
            }
            catch {
                logger.error("Error: \(error.localizedDescription)\nFile: \(file, privacy: .public)\nValue: \(logLine, privacy: .public)")
                onParsingError?(error, file, logLine)
            }
        }
        logger.debug("*** End Processing '\(file, privacy: .public)' ***")
        return result
    }
    
    /// Parses the raw log entry string  value via RegEx
    ///
    /// Some components of Configuration Manager is logging in different formats.
    /// This method tries to catch up with these formats and create a valudable result.
    ///
    /// - returns: A dictionary with the log entry components as key and its corresponding value
    private func parseRawValueToEntryTokens(for value:String) -> [String: Substring?]? {
        var items = value.namedCaptureGroupsInMatches(of: regExDefault)
        
        // check if try with the second pattern or with the message only pattern
        if items.count == 0 && value.startIndex(of: "<time=", options: [.caseInsensitive]) != nil {
            items = value.namedCaptureGroupsInMatches(of: regExAlternative)
        }
        
        // If it still is null, try the message only regex
        if items.count == 0 {
            logger.warning("Trying message only match as all other parsers failed for line '\(value, privacy: .public)'")
            items = value.namedCaptureGroupsInMatches(of: regExMsgOnly)
        }
        
        // we need at least one match
        guard items.count >= 1 else {
            logger.error("Could not parse line '\(value, privacy: .public)' with any parser!")
            return nil
        }
        return items[0]
    }
    
    /// Parses the raw string log entry to a `CmLogElement`
    /// - parameter rawValue: The raw log entry to parse
    ///
    /// - Returns: The parsed Configuration Manager log entry
    private func parseRawValue(for rawValue:String) throws -> CmLogElement? {
        guard let match = parseRawValueToEntryTokens(for: rawValue) else { throw NSError(domain: Bundle.main.bundleIdentifier!, code: 1, userInfo: ["parsedLine": rawValue]) }

        var message: String?,
            component: String?,
            context: String?,
            logLevel: CmLogType = CmLogType.Unknown,
            threadId: Int?,
            file: String?,
            timestamp: Date?,
            time: String?,
            tzAdjust: String?,
            tzOffset: String?,
            date: String?
        
        for key in match.keys {
            guard let optValue = match[key],
                  let value = optValue else { continue }
            
            switch key {
                case "Message":
                    message = String(value.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
                    break
                case "Time":
                    time = String(value)
                    break
                case "TZAdjust":
                    tzAdjust = String(value)
                    break
                case "TZOffset":
                    tzOffset = String(value)
                    break
                case "Date":
                    date = String(value)
                    break
                case "Component":
                    component = String(value)
                    break
                case "Context":
                    context = String(value)
                    break
                case "Type":
                    logLevel = CmLogType(rawValue: Int(value) ?? 0) ?? CmLogType.Unknown
                    break
                case "TID":
                    threadId = Int(value)
                    break
                case "Reference":
                    file = String(value)
                    break
                default:
                    break
            }

        }
        
        // check which time format was used for logging
        if tzAdjust != nil {
            let tzOffsetInt = Int(tzOffset ?? "") ?? 0
            
            let extractedDateValue = "\(date ?? "") \(time ?? "")\(tzAdjust ?? "")\(tzOffsetInt / 60)"
            if let dt = extractedDateValue.toDate(format: "MM-dd-yyyy HH:mm:ss.SSSZZZZZ") {
                timestamp = dt
            }
        } else if let dt = "\(date ?? "") \(time ?? "")".toDate(format: "MM-dd-yyyy HH:mm:ss.SSSSSSS") {
            timestamp = dt
        }
        
        
        guard message != nil else { return nil }
        
        return CmLogElement(message!, threadId: threadId, timestamp: timestamp ?? Date(timeIntervalSince1970: 0), component: component, logLevel: logLevel, logFile: file, context: context)
    }
    
    /// Reads the content of the given file and returns a `[String]` for each log entry of the file
    private func readFileContent(from file: URL) throws -> [String]? {
        guard FileManager.default.fileExists(atPath: file.path) else { return nil }
        
        let content = try String(contentsOfFile: file.path)
        let rawLines = content.lines
        
        let entries = combineSingleLinesToRawEntries(for: rawLines)
        
        return entries
    }

    /// Combines the single lines to valid and complete raw log entries.
    ///
    /// Loops over the conrent array of single log lines and concat the lines in case of multiline log entry to one single entry.
    /// This method also adds missing parts of the logline in case it was truncated because of the size or in case of a file rollover
    ///
    /// - parameter content: Array of the raw log lines
    /// - returns: Array of single `String`s each representing a single log entry
    private func combineSingleLinesToRawEntries (for content:[String.SubSequence]) -> [String] {
        var lines:[String] = []
        
        var currentLine:String.SubSequence = ""
        
        let zeroBasedContentCount = content.count - 1
        
        for (idx, rawLine) in content.enumerated() {
            // Check if this is the start of a new entry
            if let index = rawLine.startIndex(of: "<![LOG[") {
                // marker for new log entry found
                
                
                // If index == startIndex
                // 1. add current line to result
                // 2. reset current line to new log entry start value
                // Otherwise split at index and
                // 1. add first part of split to previous entry
                // 2. Append previous entry to the result
                // 3. reset current line to new log entry start value
                
                if index == rawLine.startIndex {
                    _ = lines.appendIfNotEmpty(currentLine)
                    
                    // Start over with a new log entry
                    currentLine = rawLine
                } else {
                    // Split the rawLine
                    let previousEntry = rawLine[..<index]
                    let newEntry = rawLine[index...]
                    
                    currentLine = currentLine.isEmpty ? previousEntry : "\(currentLine)\n\(previousEntry)"
                    _ = lines.appendIfNotEmpty(currentLine)
                    currentLine = newEntry
                }
                
                
            } else {
                // This is an additiona line for an existing entry
                currentLine = currentLine.isEmpty ? rawLine : "\(currentLine)\n\(rawLine)"
            }
            
            // if it is the last line of the content, we need to append it
            if idx == zeroBasedContentCount {
                _ = lines.appendIfNotEmpty(currentLine)
            }
        }
        
        return lines
    }
}



extension Array where Element : StringProtocol {
    /// Appends the value to the array in case it is not empty
    ///
    /// - parameter value: The value to append
    /// - returns: `true` if appended, otherwise `false
    fileprivate mutating func appendIfNotEmpty(_ value: String) -> Bool{
        guard !value.isEmpty else { return false}
        let tmp = prepareForAppend(value) as! Element
        append(tmp)
        //append(prepareForAppend(value))
        
        return true
    }
    
    /// Appends the value to the array in case it is not empty
    ///
    /// - parameter value: The value to append
    /// - returns: `true` if appended, otherwise `false
    fileprivate mutating func appendIfNotEmpty(_ value: String.SubSequence) -> Bool {
        appendIfNotEmpty(String(value))
    }
    
    /// Prepares the given value to be appended
    ///
    /// Adds the start tag and end tag for a Configuration Manager Log message entry if they are missing
    /// - parameter entry: The value to check
    /// - returns: a valid value to append
    private func prepareForAppend<T: StringProtocol>(_ entry: T) -> String {
        var line = String(entry)
        if line.startIndex(of: "<![LOG[") == nil {
            line = "<![LOG[" + line
        }
        if line.startIndex(of: "]LOG]!>") == nil {
            line = line + "]LOG]!>"
        }
        
        return line
    }
}
