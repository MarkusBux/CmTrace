//
//  ViewController.swift
//  CmTrace2
//
//  Created by Markus Bux on 16.12.20.
//

import Cocoa

class TableViewViewController: NSViewController {
    // MARK: - Interface Builder
    @IBOutlet var tableView: NSTableView!
    
    // MARK: - View Constants and variables
    private var dataStore:CmLogItems = CmLogItems()
    private var appDelegate = { NSApp.delegate as! AppDelegate }()
    
    private let warningImage = NSImage(systemSymbolName: "circle.fill", accessibilityDescription: "")!
    private let errorImage = NSImage(systemSymbolName: "circle.fill", accessibilityDescription: "")!
    private let dateFormatter:DateFormatter = (NSApp.delegate as! AppDelegate).defaultDateTimeFormater

    var presentOpenFileDialogOnLoad = false
    var highLightErrorMesssages = false {
        didSet {
            if oldValue != highLightErrorMesssages {
                reloadTableViewAndKeepSelection()
            }
        }
    }
    var highLightWarningMesssages = false {
        didSet {
            if oldValue != highLightWarningMesssages {
                reloadTableViewAndKeepSelection()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // make sure the default sort direction is asc for timestamp
        tableView.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
    }
    
    override func viewDidAppear() {
        tableView.rowSizeStyle = .small
        if presentOpenFileDialogOnLoad && !dataStore.hasLoadedData {
            let p = appDelegate.openLogFilePanel
            p.beginSheetModal(for: view.window!) { (response) in
                guard response == NSApplication.ModalResponse.OK else { return }
                self.loadFiles(p.urls)
            }
        }
    }
    
    /// Load all log entries from the given files
    ///
    /// - parameter files: The array of files to load
    func loadFiles(_ files:[URL]) {
        let p = NSStoryboard.main?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("progressController")) as? ProgressViewController
        
        self.presentAsSheet(p!)
        
        p!.totalFileCount = files.count
        p!.processedFileCount = 0

        Task {
            await dataStore.loadFileEntries(for: files, onFileProcessed: { url in
                Task {
                        self.increaseFileProcessedCount(p!)
                }
            })

            resetFormAfterLoad(p!)
        }
        
    }
    
    private func resetFormAfterLoad(_ controller : ProgressViewController) {
        self.sortTableByLastAppliedSortDescriptor()
        self.reloadTableViewAndKeepSelection()
        
        self.setWindowSubTitle()
        
        // update the toolbars and dismiss the progress view
        if let wc = self.view.window?.windowController as? WindowController {
            wc.searchTextField.stringValue = ""
            self.dismiss(controller)
        }
    }
    
    private func increaseFileProcessedCount(_ controller : ProgressViewController) {
        controller.processedFileCount += 1
    }
    
    /// Filters the current table for the given search text
    ///
    /// - parameter searchText: string that is used as filter criteria
    func applyFilter(_ searchText: String) {
        dataStore.search(searchString: searchText)
        sortTableByLastAppliedSortDescriptor()
        setWindowSubTitle(withFilteredValue: !searchText.isEmpty)
        tableView.reloadData()
    }
}

// MARK: - Private helpers
extension TableViewViewController {
    /// Sets the window title and subtitle based on the informatione provided via the view model
    ///
    /// - parameter withFilteredValue: If `true` and a filter is applied, add information about the filtered and displayed entries
    private func setWindowSubTitle(withFilteredValue:Bool = false) {
        guard dataStore.loadedFiles.count > 0 else {
            self.view.window?.subtitle = "No files loaded"
            return
        }
        
        var subTitle = dataStore.loadedFiles.count == 1 ?
            "File: \(dataStore.loadedFiles[0].lastPathComponent) (\(String(describing: self.dataStore.totalEntriesCount.formattedWithSeparator)) entries)" :
            "\(dataStore.loadedFiles.count) files loaded (\(String(describing: self.dataStore.totalEntriesCount.formattedWithSeparator)) entries)"
        
        if withFilteredValue {
            subTitle += " (Filtered: \(self.dataStore.entries.count.formattedWithSeparator))"
        }
        
        self.view.window?.subtitle = subTitle
    }

    @MainActor
    /// Reloads the table view and keeps the current selection
    private func reloadTableViewAndKeepSelection() {
        let selection = tableView.selectedRowIndexes
        tableView.reloadData()
        if let maxIndex = selection.max(), dataStore.entries.count >= maxIndex {
            tableView.selectRowIndexes(selection, byExtendingSelection: false)
        }
    }
}

// MARK: - TableView DataSource
extension TableViewViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        dataStore.entries.count
    }
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        sortTableByLastAppliedSortDescriptor()
    }
    
    fileprivate func sortTableByLastAppliedSortDescriptor () {
        let sD = tableView.sortDescriptors[0]
        dataStore.sort(by: sD.key!, asc: sD.ascending)
        reloadTableViewAndKeepSelection()
    }
}

// MARK: - TableView Delegate
extension TableViewViewController: NSTableViewDelegate {
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard tableView.selectedRow != -1 else { return }
        guard let splitViewController = parent as? NSSplitViewController else { return }
        
        let detailViewController = splitViewController.children[1]
        detailViewController.representedObject = dataStore.entries[tableView.selectedRow]
    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cellView = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: tableView) as? NSTableCellView else { return nil }
        
        let rowData = dataStore.entries[row]
        
        if cellView.identifier!.rawValue == "type" {
            if let (image, tintColor) = getLogTypeCellViewImageAndTintColor(for: rowData.logLevel, message: rowData.message) {
                cellView.imageView?.image = image
                cellView.imageView?.contentTintColor = tintColor
            } else {
                cellView.imageView?.image = nil
            }
        } else {
            switch tableColumn!.identifier.rawValue {
                case "message":
                    // Workaround for only displaying the first line of the message within the cell.
                    // Detailview will display the whole message
                    cellView.textField!.stringValue = rowData.message.components(separatedBy: .newlines)[0]
                    break
                case "timestamp":
                    cellView.textField!.stringValue = dateFormatter.string(from: rowData.timestamp)
                    break
                case "correlationId":
                    cellView.textField!.stringValue = rowData.operationId ?? ""
                    break
                case "component":
                    cellView.textField!.stringValue = rowData.component ?? ""
                    break
                default:
                    cellView.textField?.stringValue = ""
                    break
            }
        }

        return cellView
    }
    
    private func getLogTypeCellViewImageAndTintColor(for logLevel: LogItem.LogLevel, message:String) -> (NSImage, NSColor)? {
        if logLevel == .Error
            || (highLightErrorMesssages &&
                    (message.localizedCaseInsensitiveContains("error")
                        || message.localizedCaseInsensitiveContains("fail")
                    )
            ){
            return (errorImage, .systemRed)
            
        } else if logLevel == .Warning
                    || (highLightWarningMesssages &&
                            message.localizedCaseInsensitiveContains("warn")
                    ){
             return (warningImage, .systemYellow)
        }
        else {
            return nil
        }
    }
}
