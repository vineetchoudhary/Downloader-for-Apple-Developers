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

    func applicationWillFinishLaunching(_ notification: Notification) {
        //CocoaLumberjack
        DLog.config()
        DLog.info("Downloader Started.")
        
        //App Center
        if let appCenter = Bundle.main.object(forInfoDictionaryKey: "AppCenter") as? String {
            AppCenter.start(withAppSecret: appCenter, services: [Analytics.self, Crashes.self])
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        DLog.info("Downloader Finish Launching.")
        
        //Update Manager
        UpdateManager.shared.checkForUpdates { (updateURL) in
            UpdateManager.shared.showUpdateAlert(updateURL: updateURL)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        for downloadProcess in DownloadProcessManager.shared.downloadProcesses {
            downloadProcess.terminate()
        }
        DLog.info("Downloader Terminated.")
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    //MARK: - Menu Actions
    @IBAction func logsShowInFinder(_ sender: NSMenuItem) {
        logsShowInFinderActionn()
    }
    
    @IBAction func logsShowInConsoleApp(_ sender: NSMenuItem) {
        logsShowInConsoleAppAction()
    }
    
}
