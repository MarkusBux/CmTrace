//
//  LogFileParser.swift
//  CmTraceParser
//
//  Created by Markus Bux on 01.12.22.
//

import Foundation

public protocol LogFileParser{
    func canParse(_ content: String) -> Bool
    func parse(_ content: String) async -> [LogEntry]
}


