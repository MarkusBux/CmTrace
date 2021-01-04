//
//  WindowController.swift
//  CmTrace2
//
//  Created by Markus Bux on 16.12.20.
//

import Cocoa

class WindowController: NSWindowController, NSWindowDelegate {

    @IBOutlet var searchTextField: NSSearchField!
    @IBOutlet var hightlightWarning: NSButton!
    @IBOutlet var highlightError: NSButton!
    
    /// Currently loaded table view controller within the content root controller
    private var tableViewController:TableViewViewController!
    
    /// Shortcut to the Application Delegate
    private var appDelegate:AppDelegate! = {(NSApp.delegate as! AppDelegate)}()
    
    /// Internal window state for highlight error messages
    ///
    /// A change to this variable also updates the content controller, tabbar and MenuItems
    private var currentErrorState:NSControl.StateValue = .off  {
        didSet {
            tableViewController.highLightErrorMesssages = currentErrorState == .on
            highlightError.state = currentErrorState
            appDelegate.highlightErrorMenuItem.state = currentErrorState
        }
    }
    

    /// Internal window state for highlight warning messages
    ///
    /// A change to this variable also updates the content controller, tabbar and MenuItems
    private var currentWarningState:NSControl.StateValue = .off {
        didSet {
            tableViewController.highLightWarningMesssages = currentWarningState == .on
            hightlightWarning.state = currentWarningState
            appDelegate.highlightWarningMenuItem.state = currentWarningState
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // Tell the window to cascade new ones instead of placing them on top
        shouldCascadeWindows = true
    }
    
    
    
    @IBAction func applyFilter(_ sender: NSSearchField) {
        tableViewController.applyFilter(sender.stringValue)
    }
    
    @IBAction func highlightErrorMessagesClicked(_ sender: Any) {
        //if currentErrorState == .on { currentErrorState = .off } else { currentErrorState = .on }
        currentErrorState = currentErrorState.toogledOnOff()
    }
    
    @IBAction func highlightWarningMessagesClicked(_ sender: Any) {
        //if currentWarningState == .on { currentWarningState = .off } else { currentWarningState = .on }
        currentWarningState = currentWarningState.toogledOnOff()
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        // Get and assign the default table view controller
        tableViewController = ((contentViewController as! NSSplitViewController).children[0] as! TableViewViewController)
        
        tableViewController.presentOpenFileDialogOnLoad = AppPreferences.shared.presentOpenFileDialogOnLoad
        
        // We do not want to track the global state.
        // Instead we just use it as independent starting point for the view hierarchy
        currentErrorState = AppPreferences.shared.highlightErrorMessages ? .on : .off
        currentWarningState = AppPreferences.shared.highlightWarningMessages ? .on : .off
    }
    
    func windowWillClose(_ notification: Notification) {
        // Remove itself from the application delegates window controller array
        appDelegate.removeWindowController(self)
    }
    
    func windowDidBecomeMain(_ notification: Notification) {
        // Update the MenuItem state to reflect the current state for highlighting
        appDelegate.highlightErrorMenuItem.state = currentErrorState
        appDelegate.highlightWarningMenuItem.state = currentWarningState
    }

}

extension NSControl.StateValue {
    fileprivate func toogledOnOff() -> NSControl.StateValue {
        if self == .on {
            return .off
        } else {
            return .on
        }
    }
}
