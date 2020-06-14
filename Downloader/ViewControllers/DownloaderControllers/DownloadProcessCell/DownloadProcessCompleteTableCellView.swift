//
//  DownloadProcessCompleteTableCellView.swift
//  Downloader
//
//  Created by Vineet Choudhary on 14/06/20.
//  Copyright © 2020 Developer Insider. All rights reserved.
//

import Cocoa

class DownloadProcessCompleteTableCellView: NSTableCellView {

    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var messageLabel: NSTextField!
    
    func config(downloadProgress: DownloadProgress) {
        nameLabel.stringValue = downloadProgress.fileName ?? "--"
        messageLabel.stringValue = NSLocalizedString("DownloadCompleted", comment: "")
    }
}
