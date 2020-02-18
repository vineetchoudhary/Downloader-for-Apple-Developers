//
//  AppDelegate.swift
//  DeveloperToolsDownloader
//
//  Created by Vineet Choudhary on 17/02/20.
//  Copyright © 2020 Developer Insider. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        for downloadProcess in DownloadProcessManager.shared.downloadProcesses.values {
            downloadProcess.terminate()
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}

