//
//  DownloadProcessManager.swift
//  DeveloperToolsDownloader
//
//  Created by Vineet Choudhary on 18/02/20.
//  Copyright © 2020 Developer Insider. All rights reserved.
//

import Foundation

class DownloadProcessManager {
    //MARK: - Constants
    let downloadCompletedResult = "download completed"
    
    //MARK: - Properties
    var downloadAuthToken: String?
    private(set) var downloadProcesses = [String: Process]()
    
    
    //MARK: - Initializers
    static let shared = DownloadProcessManager()
    private init() {
    }
    
    //MARK: - Download Helper
    func startDownload(fileURL: String?, outputStream: @escaping (String)-> Void) {
        guard let downloadAuthToken = downloadAuthToken else {
            outputStream("Download authentication token not found.\n")
            return
        }
        guard var downloadFileURL = fileURL else {
            outputStream("Download url not found.\n")
            return
        }
        
        //use http protocol instead of https
        downloadFileURL = downloadFileURL.replacingOccurrences(of: "https://", with: "http://")
        
        //create or use existing download process
        var currentDownloadProcess: Process!
        currentDownloadProcess = downloadProcesses[downloadFileURL]
        if currentDownloadProcess == nil {
            currentDownloadProcess = Process()
            downloadProcesses[downloadFileURL] = currentDownloadProcess
        }
        
        if currentDownloadProcess.isRunning {
            outputStream("Please wait. Download in progress....\n")
            return
        }

        let aria2c = Bundle.main.path(forResource: "aria2c", ofType: nil)!
        let launchPath = Bundle.main.path(forResource: "AppleMoreDownload", ofType: "sh")
        currentDownloadProcess.launchPath = launchPath
        currentDownloadProcess.arguments = [aria2c, downloadFileURL, downloadAuthToken]
        
        let outputPipe = Pipe()
        currentDownloadProcess.standardOutput = outputPipe
        currentDownloadProcess.standardError = outputPipe
        outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        
        var notificationObserver: NSObjectProtocol?
        notificationObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outputPipe.fileHandleForReading, queue: .main) { [unowned self] (notification) in
            let outputData = outputPipe.fileHandleForReading.availableData
            if outputData.count > 0, let outputString = String.init(data: outputData, encoding: .utf8) {
                if outputString.lowercased().contains(self.downloadCompletedResult) {
                    outputStream("Download Completed. Please check your download folder.")
                } else {
                    outputStream(outputString)
                }
                outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
            } else if let notificationObserver = notificationObserver {
                currentDownloadProcess.terminate()
                self.downloadProcesses.removeValue(forKey: downloadFileURL)
                NotificationCenter.default.removeObserver(notificationObserver)
            }
        }
        
        currentDownloadProcess.launch()
    }
    
}
