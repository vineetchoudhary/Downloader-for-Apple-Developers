//
//  DownloadProcessManager.swift
//  DeveloperToolsDownloader
//
//  Created by Vineet Choudhary on 18/02/20.
//  Copyright © 2020 Developer Insider. All rights reserved.
//

import Foundation

class DownloadProcessManager {
    typealias OutputStream = (String)-> Void
    
    //MARK: - Constants
    let downloadCompletedResult = "download completed"
    
    //MARK: - Properties
    var downloadAuthToken: String?
    private(set) var downloadLogs = String()
    private(set) var downloadProcesses = [String: Process]()
    
    
    //MARK: - Initializers
    static let shared = DownloadProcessManager()
    private init() {
    }
    
    //MARK: - Download Helper
    func startDownload(fileURL: String?, outputStream: @escaping OutputStream) {
        guard let downloadAuthToken = downloadAuthToken else {
            let outputString = NSLocalizedString("DownloadAuthTokenNotFound", comment: "")
            sendOutputStream(outputString: outputString, outputStream: outputStream)
            return
        }
        guard var downloadFileURL = fileURL else {
            let outputString = NSLocalizedString("DownloadURLNotFound", comment: "")
            sendOutputStream(outputString: outputString, outputStream: outputStream)
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
            let outputString = NSLocalizedString("DownloadInProgress", comment: "")
            sendOutputStream(outputString: outputString, outputStream: outputStream)
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
                    let downloadCompleted = NSLocalizedString("DownloadComplete", comment: "")
                    self.sendOutputStream(outputString: outputString, outputStream: outputStream)
                    self.sendOutputStream(outputString: downloadCompleted, outputStream: outputStream)
                } else {
                    self.sendOutputStream(outputString: outputString, outputStream: outputStream)
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
    
    private func sendOutputStream(outputString: String, outputStream: OutputStream) {
        outputStream(outputString)
        downloadLogs.append(outputString)
        NotificationCenter.default.post(name: .DownloadOutputStream, object: outputString)
    }
}

extension Notification.Name {
    static let DownloadOutputStream = Notification.Name("DownloadOutputStream")
}
