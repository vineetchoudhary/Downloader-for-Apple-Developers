//
//  DownloadSourceTableViewHandler.swift
//  Downloader
//
//  Created by Vineet Choudhary on 17/05/20.
//  Copyright © 2020 Developer Insider. All rights reserved.
//

import Foundation
import Cocoa

typealias DownloadSourceChange = (_ downloadSource: DownloadSource) -> Void

class DownloadSourceTableViewHandler: NSObject {
    private var downloadSourceChangeClosur: DownloadSourceChange?
    
    init(tableView: NSTableView) {
        super.init()
        tableView.delegate = self;
        tableView.dataSource = self;
    }
    
    func selectionChange(downloadSourceChange: @escaping DownloadSourceChange) {
        downloadSourceChangeClosur = downloadSourceChange
        downloadSourceChange(DownloadSource.allCases.first!)
    }
}

extension DownloadSourceTableViewHandler: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return DownloadSource.allCases.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let identifier = NSUserInterfaceItemIdentifier(rawValue: "downloadServiceTableViewCell")
        if let cell = tableView.makeView(withIdentifier: identifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = DownloadSource.allCases[row].title
            return cell;
        }
        return nil
    }
}

extension DownloadSourceTableViewHandler: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        downloadSourceChangeClosur?(DownloadSource.allCases[row])
        return true
    }
}
