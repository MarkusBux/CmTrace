//
//  ParserRegistry.swift
//  CmTraceParser
//
//  Created by Markus Bux on 01.12.22.
//

import Foundation

public protocol ParserRegistryProtocol {
    func getParser(for content: String) -> (any LogFileParser)?
    func registerParser(_ parser: any LogFileParser)
}
