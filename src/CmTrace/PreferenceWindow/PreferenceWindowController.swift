//
//  PreferenceWindowController.swift
//  CmTrace2
//
//  Created by Markus Bux on 17.12.20.
//

import Cocoa

class PreferenceWindowController: NSWindowController, NSWindowDelegate {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        
        // Hide the window instead of closing
        self.window?.orderOut(sender)
        return false
    }
}
