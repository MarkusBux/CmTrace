//
//  CmLogFileLoader.swift

//  CmTraceParser
//
//  Created by Markus Bux on 01.12.22.
//

import Foundation

public class CmLogFileLoader {
    
    private var parserRegistry: any ParserRegistryProtocol
    
    public init() {
        self.parserRegistry = ParserRegistry([CmTraceParser(), CmTraceParser2()])
    }
    
    public init(_ parserRegistry: any ParserRegistryProtocol) {
        self.parserRegistry = parserRegistry
    }
        
    /// Handler instance using the default parserRegistry
    public static let Default = CmLogFileLoader()
    
    public func ParseFile(_ file: URL) async throws -> [LogEntry] {
        let fileContent = try await readFileContent(from: file)
        
        guard let parser = parserRegistry.getParser(for: fileContent) else {
            throw LogFileLoaderError.noValidParserForContentFound
        }

        return await parser.parse(fileContent)
    }
    

    private func readFileContent(from file: URL) async throws-> String {
        //guard FileManager.default.fileExists(atPath: file.path) else { return nil }
        let loadContentTask = Task { () -> String in
            return try String(contentsOfFile: file.path)
        }
        
        return try await loadContentTask.value
    }
}
