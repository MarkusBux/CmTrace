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
    
    /// Currently loaded view controllers
    private lazy var tableViewController:TableViewViewController! = { splitViewController.children[0] as! TableViewViewController }()
    private lazy var detailViewController:NSViewController! = { splitViewController.children[1] }()
    private lazy var splitViewController: NSSplitViewController = { self.contentViewController as! NSSplitViewController }()
    
    private let errorIconOn = "xmark.octagon.fill"
    private let errorIconOff = "xmark.octagon"
    private let warningIconOn = "exclamationmark.triangle.fill"
    private let warningIconOff = "exclamationmark.triangle"

    
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
            
            guard let tb = touchBar else { return }
            guard let tbb = tb.item(forIdentifier: .highlightError)?.view as? NSButton else { return }
            tbb.image = NSImage(systemSymbolName: currentErrorState == .on ? errorIconOn : errorIconOff, accessibilityDescription: nil)!
            tbb.bezelColor = currentErrorState == .on ? .systemRed : .clear
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
            
            guard let tb = touchBar else { return }
            guard let tbb = tb.item(forIdentifier: .highlightWarning)?.view as? NSButton else { return }
            tbb.image = NSImage(systemSymbolName: currentWarningState == .on ? warningIconOn : warningIconOff, accessibilityDescription: nil)!
            tbb.bezelColor = currentWarningState == .on ? .systemYellow : .clear

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
    
    @IBAction func collapseDetailViewToogle(_ sender: Any) {
        guard let detailSplitItem = splitViewController.splitViewItem(for: detailViewController) else { return }
        detailSplitItem.animator().isCollapsed.toggle()
        appDelegate.detailViewMenuItem.title = detailSplitItem.isCollapsed ? "Show Detail View" : "Hide Detail View"
    }
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
        // Set the default preference for openDialog on new window
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

// MARK: - Touch Bar Handling
extension NSTouchBarItem.Identifier {
    static let cmTraceLabel = NSTouchBarItem.Identifier("com.markusbux.CmTrace.cmtracelabel")
    static let highlightError = NSTouchBarItem.Identifier("com.markusbux.CmTrace.highlighterror")
    static let highlightWarning = NSTouchBarItem.Identifier("com.markusbux.CmTrace.highlightwarning")
    static let toogleDetailView = NSTouchBarItem.Identifier("com.markusbux.CmTrace.toogledetailview")
    static let activateSearch = NSTouchBarItem.Identifier("com.markusbux.CmTrace.activateSearch")
}

extension WindowController: NSTouchBarDelegate {
    override func makeTouchBar() -> NSTouchBar? {
        // enable the Customize Touch Bar menu item
        NSApp.isAutomaticCustomizeTouchBarMenuItemEnabled = true
        
        // create a Touch Bar with a unique identifier, making `self` its delegate
        let touchBar = NSTouchBar()
        touchBar.customizationIdentifier = NSTouchBar.CustomizationIdentifier("com.markusbux.CmTrace")
        touchBar.delegate = self
        
        // set up some meaningful defaults, also allow sub touchbars to be visible
        touchBar.defaultItemIdentifiers = [.cmTraceLabel, .activateSearch, .highlightError, .highlightWarning, .toogleDetailView, .otherItemsProxy]
        
        // make the address entry button sit in the center of the bar
        //touchBar.principalItemIdentifier = .toogleDetailView
        
        // allow the user to customize these four controls
        touchBar.customizationAllowedItemIdentifiers = [.activateSearch, .highlightError, .highlightWarning, .toogleDetailView]
        
        // but don't let them take off the URL entry button
        touchBar.customizationRequiredItemIdentifiers = [.highlightError, .highlightWarning]
        
        return touchBar
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
            case .cmTraceLabel:
                let label = NSTextField(labelWithString: "CmTrace: ")
                let customItem = NSCustomTouchBarItem(identifier: identifier)
                customItem.view = label
                customItem.customizationLabel = "CmTrace Label"
                return customItem
            case .highlightError:
                let button = NSButton(image: NSImage(systemSymbolName: currentErrorState == .on ? errorIconOn : errorIconOff, accessibilityDescription: nil)!, target: self, action: #selector(highlightErrorMessagesClicked(_:)))
                let customTouchBarItem = NSCustomTouchBarItem(identifier: identifier)
                customTouchBarItem.view = button
                customTouchBarItem.customizationLabel = "Highlight Error Messages"
                return customTouchBarItem
            case .highlightWarning:
                let button = NSButton(image: NSImage(systemSymbolName: currentWarningState == .on ? warningIconOn : warningIconOff, accessibilityDescription: nil)!, target: self, action: #selector(highlightWarningMessagesClicked(_:)))
                let customTouchBarItem = NSCustomTouchBarItem(identifier: identifier)
                customTouchBarItem.view = button
                customTouchBarItem.customizationLabel = "Highlight Warning Messages"
                return customTouchBarItem
            case .toogleDetailView:
                let button = NSButton(title: "Show/Hide Detail View", target: self, action: #selector(collapseDetailViewToogle(_:)))
                let customTouchBarItem = NSCustomTouchBarItem(identifier: identifier)
                customTouchBarItem.view = button
                customTouchBarItem.customizationLabel = "Show/Hide Detail View"
                return customTouchBarItem
            case .activateSearch:
                let button = NSButton(image: NSImage(named: NSImage.touchBarSearchTemplateName)!, target: self, action: #selector(activateSearch(_:)))
                
                let customTouchBarItem = NSCustomTouchBarItem(identifier: identifier)
                customTouchBarItem.customizationLabel = "Search"
                customTouchBarItem.view = button
                return customTouchBarItem
            default:
                return nil
        }
    }
    
    @objc private func activateSearch(_ sender: NSButton) {
        window?.makeFirstResponder(searchTextField)
    }
    
    override func cancelOperation(_ sender: Any?) {
        window?.makeFirstResponder(contentViewController)
    }
}

// MARK: - StateValue Extensions
extension NSControl.StateValue {
    fileprivate func toogledOnOff() -> NSControl.StateValue {
        if self == .on {
            return .off
        } else {
            return .on
        }
    }
}
