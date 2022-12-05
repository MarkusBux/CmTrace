//
//  DetailViewController.swift
//  CmTrace
//
//  Created by Markus Bux on 05.12.22.
//

import Foundation
import Cocoa

class DetailViewController: NSViewController {
    
  
    @IBOutlet weak var severityLabel: NSTextField!
    @objc dynamic var logLevel:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    public func displayLogItem(_ item: LogItem) {
        self.representedObject = item
        setSeverity(item.logLevel)
    }
    
    private func setSeverity(_ logLevel: LogItem.LogLevel?) {
        guard let severity = logLevel else {return}
        
        switch severity{
            case .Information:
                self.severityLabel.drawsBackground = true
                self.severityLabel.backgroundColor = .systemBlue
                self.logLevel =  "Information"
            case .Error:
                self.severityLabel.drawsBackground = true
                self.severityLabel.backgroundColor = .systemRed
                self.logLevel =  "Error"
            case .Warning:
                self.severityLabel.drawsBackground = true
                self.severityLabel.backgroundColor = .systemYellow
                self.logLevel =  "Warning"
            default:
                self.severityLabel.drawsBackground = false
                self.logLevel = "N/A"
        }
    }
}

class SeverityTransformer : ValueTransformer {
    
    override func valueClassForBinding(_ binding: NSBindingName) -> AnyClass? {
        return NSString.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let severity = value as? LogItem.LogLevel else {return nil}
        
        switch severity{
            case .Information:
                return "Information"
            case .Error:
                return "Error"
            case .Warning:
                return "Warning"
            default:
                return nil
        }
    }
}

extension NSValueTransformerName {
    static let severityTransformerName = NSValueTransformerName("SeverityTransformer")
}
