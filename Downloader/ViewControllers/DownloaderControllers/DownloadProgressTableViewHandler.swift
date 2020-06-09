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
        let identifier = NSUserInterfaceItemIdentifier(rawValue: "downloadProgressTableViewCell")
        if let cell = tableView.makeView(withIdentifier: identifier, owner: nil) as? NSTableCellView {
            let processes = DownloadProcessManager.shared.downloadProcesses
            cell.textField?.stringValue = processes[row].lastOutput ?? "Waiting..."
            return cell;
        }
        return nil
    }
}

extension DownloadProgressTableViewHandler: NSTableViewDelegate {
    
}
