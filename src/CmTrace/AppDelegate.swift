//
//  AppDelegate.swift
//  CmTrace2
//
//  Created by Markus Bux on 11.12.20.
//

import Cocoa
import os
import UniformTypeIdentifiers


@main
class AppDelegate: NSObject, NSApplicationDelegate {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "\(AppDelegate.self)")
    
    @IBOutlet weak var highlightErrorMenuItem: NSMenuItem!
    @IBOutlet weak var highlightWarningMenuItem: NSMenuItem!
    @IBOutlet weak var detailViewMenuItem: NSMenuItem!
    
    
    private var preferencesController:NSWindowController?
    
    /// Created and active `WindowController`s
    private var windowControllers:[WindowController] = []
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
    
    @IBAction func showPreferences(_ sender: Any) {
        if preferencesController == nil {
            let storyboard = NSStoryboard(name: NSStoryboard.Name("Preferences"), bundle: nil)
            preferencesController = storyboard.instantiateInitialController() as? NSWindowController
        }
        
        preferencesController?.showWindow(self)
    }
    
    @IBAction func newDocument(_ sender:Any?) {
        if let mainWindowController = NSStoryboard.main?.instantiateInitialController() as? WindowController {
            windowControllers.append(mainWindowController)
            mainWindowController.showWindow(self)
        }
    }
    
    @IBAction func openDocument(_ sender:Any?) {
        let p = openLogFilePanel
        p.beginSheetModal(for: NSApp.mainWindow!) { result in
            guard result == NSApplication.ModalResponse.OK else { return }
            
            for url in p.urls {
                NSDocumentController.shared.noteNewRecentDocumentURL(url)
            }
            self.openFilesWithMainWindow(p.urls)
        }
    }
    
    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        logger.debug("Try to open: '\(filenames)'")
        let urls = filenames.compactMap({URL(fileURLWithPath: $0)})
        guard urls.count > 0 else {
            logger.error("Could not convert any filename to a valid URL!")
            return
        }
        openFilesWithMainWindow(urls)
    }
    
    private func openFilesWithMainWindow(_ files:[URL]) {
        guard let splitController = NSApp.mainWindow?.contentViewController as? NSSplitViewController else { return }
        guard let contentController = splitController.children[0] as? TableViewViewController else { return }
        contentController.loadFiles(files)
    }
    
    func removeWindowController(_ controller: WindowController) {
        windowControllers.removeAll { $0 === controller}
    }
    
}


extension AppDelegate {
    /// Default DateTime Formatter
    var defaultDateTimeFormater: DateFormatter {
        let f = DateFormatter()
        f.locale = Locale.current
        f.calendar = Calendar.current
        f.timeZone = TimeZone.current
        f.dateFormat = "yyyy-MM-dd HH:mm:ss.sss"
        return f
    }
    
    /// Shared preconfigured NSOpenPanel
    var openLogFilePanel:NSOpenPanel {
        let p = NSOpenPanel()
        p.allowsMultipleSelection = true
        p.canChooseDirectories = false
        p.canChooseFiles = true
        p.allowedContentTypes = [.log]
        return p
    }
}
