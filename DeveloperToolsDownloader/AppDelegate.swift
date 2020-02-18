//
//  AppDelegate.swift
//  DeveloperToolsDownloader
//
//  Created by Vineet Choudhary on 17/02/20.
//  Copyright © 2020 Developer Insider. All rights reserved.
//

import Cocoa
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let appCenter = Bundle.main.object(forInfoDictionaryKey: "AppCenter") as? String {
            MSAppCenter.start(appCenter, withServices:[MSAnalytics.self, MSCrashes.self])
        }
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

