//
//  ProgressViewController.swift
//  CmTrace
//
//  Created by Markus Bux on 22.12.20.
//

import Cocoa

class ProgressViewController: NSViewController {

    @IBOutlet var fileLabel: NSTextField!
    @IBOutlet var progress: NSProgressIndicator!
    
    var totalFileCount:Int = 0 {
        didSet {
            progress.maxValue = Double(totalFileCount)
        }
    }
    
    var processedFileCount:Int = 0 {
        didSet {
            fileLabel.stringValue = "\(processedFileCount) / \(totalFileCount)"
            progress.doubleValue = Double(processedFileCount)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
}
