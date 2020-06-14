//
//  DownnloadProcessTableCellView.swift
//  Downloader
//
//  Created by Vineet Choudhary on 14/06/20.
//  Copyright © 2020 Developer Insider. All rights reserved.
//

import Cocoa

class DownloadProcessTableCellView: NSTableCellView {

    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var progressLabel: NSTextField!
    @IBOutlet weak var downloadSpeedLabel: NSTextField!
    @IBOutlet weak var expectedTimeLabel: NSTextField!
    @IBOutlet weak var connectionsLabel: NSTextField!
    
    func config(downloadProgress: DownloadProgress) {
        progressLabel.stringValue = downloadProgress.progress ?? "--"
        connectionsLabel.stringValue = downloadProgress.connections ?? "--"
        expectedTimeLabel.stringValue = downloadProgress.expectedTime ?? "--"
        downloadSpeedLabel.stringValue = downloadProgress.downloadSpeed ?? "--"
        nameLabel.stringValue = downloadProgress.fileName ?? downloadProgress.gid ?? "--"
    }
    
}
