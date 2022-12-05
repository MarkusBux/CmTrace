//
//  LogFileParserRegistry.swift
//  CmTraceParser
//
//  Created by Markus Bux on 01.12.22.
//

import Foundation

public class ParserRegistry: ParserRegistryProtocol {
    
    private var parsers:[any LogFileParser] = []
    
    public init(){}
    
    public init(_ parser : any LogFileParser) {
        parsers.append(parser)
    }
    
    public init(_ parsers : [any LogFileParser]) {
        self.parsers.append(contentsOf: parsers)
    }
    
    public func getParser(for content: String) -> (any LogFileParser)? {
        for parser in parsers {
            guard parser.canParse(content) else { continue }
            
            return parser
        }
        
        return nil
    }
    
    public func registerParser(_ parser: any LogFileParser) {
        if !parsers.contains(where: { p in type(of: p) == type(of: parser) })
        {
            parsers.append(parser)
        }
    }
}
