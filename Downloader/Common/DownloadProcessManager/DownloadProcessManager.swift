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
    
    //MARK: - Properties
    private(set) var downloadAuthToken: String?
    private(set) var downloadLogs = String()
    private(set) var downloadProcesses = [String: Process]()
    
    
    //MARK: - Initializers
    static let shared = DownloadProcessManager()
    private init() {
    }
    
    //MARK: - Download Helper
    func setDownloadAuthToken(token: String) {
        downloadAuthToken = token
    }
    
    func startDownload(fileURL: String?, outputStream: @escaping OutputStream) {
        guard let authToken = downloadAuthToken else {
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
        currentDownloadProcess.arguments = [aria2c, downloadFileURL, authToken]
        
        let outputPipe = Pipe()
        currentDownloadProcess.standardOutput = outputPipe
        currentDownloadProcess.standardError = outputPipe
        outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        
        var notificationObserver: NSObjectProtocol?
        notificationObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outputPipe.fileHandleForReading, queue: .main) { [unowned self] (notification) in
            outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
            let outputData = outputPipe.fileHandleForReading.availableData
            if outputData.count > 0, let outputString = String.init(data: outputData, encoding: .utf8) {
                self.sendOutputStream(outputString: Aria2cParser.parse(string: outputString), outputStream: outputStream)
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
        downloadLogs.append("\(outputString)\n")
        NotificationCenter.default.post(name: .DownloadOutputStream, object: "\(outputString)\n")
    }
}

extension Notification.Name {
    static let DownloadOutputStream = Notification.Name("DownloadOutputStream")
}
