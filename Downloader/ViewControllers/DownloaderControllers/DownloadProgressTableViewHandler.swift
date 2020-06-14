//
//  DownloadProgressTableViewHandler.swift
//  Downloader
//
//  Created by Vineet Choudhary on 17/05/20.
//  Copyright © 2020 Developer Insider. All rights reserved.
//

import Foundation
import Cocoa

class DownloadProgressTableViewHandler: NSObject {
    init(tableView: NSTableView) {
        super.init()
        tableView.delegate = self;
        tableView.dataSource = self;
    }
}

extension DownloadProgressTableViewHandler: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return DownloadProcessManager.shared.downloadProcesses.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let identifierString = String(describing: DownloadProcessTableCellView.self)
        let identifier = NSUserInterfaceItemIdentifier(rawValue: identifierString)
        if let cell = tableView.makeView(withIdentifier: identifier, owner: nil) as? DownloadProcessTableCellView,
            let downloadProgress = DownloadProcessManager.shared.downloadProcesses[row].progress {
            cell.config(downloadProgress: downloadProgress)
            return cell
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
}

extension DownloadProgressTableViewHandler: NSTableViewDelegate {
    
}
