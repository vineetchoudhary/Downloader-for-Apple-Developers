//
//  DownloadServiceTableViewHandler.swift
//  Downloader
//
//  Created by Vineet Choudhary on 17/05/20.
//  Copyright © 2020 Developer Insider. All rights reserved.
//

import Foundation
import Cocoa

typealias DownloadURLChange = (_ downloadURL: DownloadURL) -> Void

class DownloadServiceTableViewHandler: NSObject {
    private var downloadURLChangeClosur: DownloadURLChange?
    
    init(tableView: NSTableView) {
        super.init()
        tableView.delegate = self;
        tableView.dataSource = self;
    }
    
    func selectionChange(downloadURLChange: @escaping DownloadURLChange) {
        downloadURLChangeClosur = downloadURLChange
    }
}

extension DownloadServiceTableViewHandler: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return DownloadURL.allCases.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let identifier = NSUserInterfaceItemIdentifier(rawValue: "downloadServiceTableViewCell")
        if let cell = tableView.makeView(withIdentifier: identifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = DownloadURL.allCases[row].title
            return cell;
        }
        return nil
    }
}

extension DownloadServiceTableViewHandler: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        downloadURLChangeClosur?(DownloadURL.allCases[row])
        return true
    }
}
