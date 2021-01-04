//
//  GeneralPreferenceController.swift
//  CmTrace2
//
//  Created by Markus Bux on 17.12.20.
//

import Cocoa

class GeneralPreferenceController: NSViewController {

    @IBOutlet var openFileDialog: NSButton!
    @IBOutlet var highlightWarning: NSButton!
    @IBOutlet var highlightError: NSButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height)
        
        
        openFileDialog.state = AppPreferences.shared.presentOpenFileDialogOnLoad ? .on : .off
        highlightWarning.state = AppPreferences.shared.highlightWarningMessages ? .on : .off
        highlightError.state = AppPreferences.shared.highlightErrorMessages ? .on : .off
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        self.parent?.view.window?.title = "Preferences - \(self.title ?? "General")"
    }
    
    @IBAction func openFileDialogClicked(_ sender: NSButton) {
        AppPreferences.shared.presentOpenFileDialogOnLoad.toggle()
    }
    
    @IBAction func highlightWarningClicked(_ sender: NSButton) {
        AppPreferences.shared.highlightWarningMessages.toggle()
    }
    
    @IBAction func highlightErrorClicked(_ sender: NSButton) {
        AppPreferences.shared.highlightErrorMessages.toggle()
    }
}
