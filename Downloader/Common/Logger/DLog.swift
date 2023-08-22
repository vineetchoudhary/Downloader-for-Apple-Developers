//
//  DLog.swift
//  Downloader
//
//  Created by Vineet Choudhary on 21/06/20.
//  Copyright © 2020 Developer Insider. All rights reserved.
//

import Foundation
import CocoaLumberjackSwift

struct DLog {
    private static let fileLogger = DDFileLogger()
    private static var ddLogLevel: DDLogLevel = .info

    static var sortedLogFilePath: [String] {
        return fileLogger.logFileManager.sortedLogFilePaths
    }
    
    private init() {
    }
    
    static func config() {
        //Add OS Logger
        DDLog.add(DDOSLogger.sharedInstance)
        
        //Add TTYLogger (for Xcode)
        if let ttyLogger = DDTTYLogger.sharedInstance {
            DDLog.add(ttyLogger)
        }
        
        //Config and Add File Logger
        fileLogger.doNotReuseLogFiles = true
        fileLogger.logFileManager.maximumNumberOfLogFiles = 3;
        DDLog.add(fileLogger)
    }
    
    static func openLatestLogFile() {
        if let latestLogFilePath = DLog.sortedLogFilePath.first {
            NSWorkspace.shared.openFile(latestLogFilePath)
        }
    }
    
    static func verbose(_ message: String) {
        DDLogVerbose(message)
    }
    
    static func debug(_ message: String) {
        DDLogDebug(message)
    }
    
    static func info(_ message: String) {
        DDLogInfo(message)
    }
    
    static func warning(_ message: String) {
        DDLogWarn(message)
    }
    
    static func error(_ message: String) {
        DDLogError(message)
    }
}
