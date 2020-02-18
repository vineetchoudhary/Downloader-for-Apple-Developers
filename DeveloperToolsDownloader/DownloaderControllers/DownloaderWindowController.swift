//
//  DownloaderWindowController.swift
//  DeveloperToolsDownloader
//
//  Created by Vineet Choudhary on 18/02/20.
//  Copyright © 2020 Developer Insider. All rights reserved.
//

import Foundation
import Cocoa

class DownloaderWindowController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
    }
}

extension DownloaderWindowController: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        if DownloadProcessManager.shared.downloadProcesses.count > 0 {
            let alert = NSAlert()
            alert.messageText = "Are you sure you want to close Downloader?"
            alert.informativeText = "Closing this will stop the download task."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "Stop Downloading")
            alert.addButton(withTitle: "No")
            if alert.runModal() == .alertFirstButtonReturn {
                return true
            }
            return false
        } else {
            return true
        }
    }
}
