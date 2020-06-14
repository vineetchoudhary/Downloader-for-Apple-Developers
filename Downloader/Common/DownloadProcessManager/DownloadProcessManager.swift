//
//  DownloadProcessManager.swift
//  DeveloperToolsDownloader
//
//  Created by Vineet Choudhary on 18/02/20.
//  Copyright © 2020 Developer Insider. All rights reserved.
//

import Foundation

class DownloadProcessManager {
    //MARK: - Properties
    private(set) var downloadAuthToken: String?
    weak var delegate: DownloadProcessDelegate?
    lazy private(set) var downloadProcesses = [DownloadProcess]()
    
    //MARK: - Initializers
    static let shared = DownloadProcessManager()
    private init() {
    }
    
    //MARK: - Download Helper
    func setDownloadAuthToken(token: String) {
        downloadAuthToken = token
    }
    
    //MARK: - Start Download
    func startDownload(source: DownloadSource, fileURL: String?) {
        guard var downloadFileURL = fileURL else {
            let outputString = NSLocalizedString("DownloadURLNotFound", comment: "")
            delegate?.outputStream(output: outputString)
            return
        }
        
        //use http protocol instead of https
        downloadFileURL = downloadFileURL.replacingOccurrences(of: "https://", with: "http://")
        
        var launchPath: String
        var launchArguments = [String]()
        
        //Add aria2c path
        let aria2cPath = Bundle.main.path(forResource: "aria2c", ofType: nil)!
        launchArguments.append(aria2cPath)
        
        //Add download URL
        launchArguments.append(downloadFileURL)
        
        //Set/Add Source Specific Variable/Arguments
        switch source {
            case .tools:
                launchPath = Bundle.main.path(forResource: "AppleMoreDownload", ofType: "sh")!
                
                //Get download auth token and add to launch arguments
                guard let authToken = downloadAuthToken else {
                    let outputString = NSLocalizedString("DownloadAuthTokenNotFound", comment: "")
                    delegate?.outputStream(output: outputString)
                    return
                }
                launchArguments.append(authToken);
            case .video:
                launchPath = Bundle.main.path(forResource: "AppleVideoDownload", ofType: "sh")!
        }
        
        //create or use existing download process
        var currentDownloadProcess: DownloadProcess!
        currentDownloadProcess = downloadProcesses.first(where: { $0.url == downloadFileURL })
        if currentDownloadProcess == nil {
            currentDownloadProcess = DownloadProcess(url: downloadFileURL)
            downloadProcesses.append(currentDownloadProcess)
        }
        
        //Check if download already in process for same url
        if currentDownloadProcess.isRunning {
            let outputString = NSLocalizedString("DownloadInProgress", comment: "")
            delegate?.outputStream(output: outputString)
            return
        }

        //Set launch path and arguments
        currentDownloadProcess.launchPath = launchPath
        currentDownloadProcess.arguments = launchArguments
        
        //set standard ourput and error pipe
        let outputPipe = Pipe()
        currentDownloadProcess.standardOutput = outputPipe
        currentDownloadProcess.standardError = outputPipe
        outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        
        //observer output changes
        var notificationObserver: NSObjectProtocol?
        notificationObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outputPipe.fileHandleForReading, queue: .main) { [unowned self] (notification) in
            outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
            
            let fileName = (downloadFileURL as NSString).lastPathComponent
            let outputData = outputPipe.fileHandleForReading.availableData
            
            //If there is some output data means process is running
            if outputData.count > 0, let outputString = String.init(data: outputData, encoding: .utf8) {
                //update progress
                let parsedOutputString = Aria2cParser.parse(string: outputString)
                if (!parsedOutputString.isEmpty) {
                    currentDownloadProcess.progress = DownloadProgress(fileName: fileName, output: parsedOutputString)
                    print(currentDownloadProcess.progress.debugDescription)
                }
                
                //trigger output stream update
                self.delegate?.outputStream(output: parsedOutputString)
            } else if let notificationObserver = notificationObserver {
                //update progress
                currentDownloadProcess.progress = DownloadProgress(fileName: fileName, output: "", isFinish: true)
                
                //trigger download finish
                self.delegate?.downloadFinish(url: downloadFileURL)
                
                //terminate current download process and remove process output observer
                currentDownloadProcess.terminate()
                NotificationCenter.default.removeObserver(notificationObserver)
            }
        }
        
        //launch download process
        currentDownloadProcess.launch()
        
        //trigger downnload start
        self.delegate?.downloadStart(url: downloadFileURL)
    }
}
