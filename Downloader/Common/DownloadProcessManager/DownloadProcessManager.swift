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
    private(set) var downloadQueue: OperationQueue!
    weak var delegate: DownloadProcessDelegate?
    lazy private(set) var downloadProcesses = [DownloadProcess]()
    
    //MARK: - Initializers
    static let shared = DownloadProcessManager()
    private init() {
        downloadQueue = OperationQueue()
        downloadQueue.name = "Download Queue"
    }
    
    //MARK: - Download Helper
    func setDownloadAuthToken(token: String) {
        downloadAuthToken = token
    }
    
    //MARK: - Start Download
    func startDownload(source: DownloadSource, fileURL: String?) {
        guard var downloadFileURLString = fileURL,
            let downloadFileURL = URL(string: downloadFileURLString) else {
            let outputString = NSLocalizedString("DownloadURLNotFound", comment: "")
            delegate?.outputStream(output: outputString)
            return
        }

        let fileExtension = downloadFileURL.pathExtension
        let lastPathComponent = downloadFileURL.lastPathComponent
        let fileName = lastPathComponent.components(separatedBy: fileExtension).first!
        let fullFileName = fileName + fileExtension
        
        //use http protocol instead of https
        downloadFileURLString = downloadFileURLString.replacingOccurrences(of: "https://", with: "http://")
        
        var launchPath: String
        var launchArguments = [String]()
        
        //Add aria2c path
        let aria2cPath = Bundle.main.path(forResource: "aria2c", ofType: nil)!
        launchArguments.append(aria2cPath)
        
        //Add download URL
        launchArguments.append(downloadFileURLString)
        
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
        currentDownloadProcess = downloadProcesses.first(where: { $0.url == downloadFileURLString })
        if currentDownloadProcess == nil {
            currentDownloadProcess = DownloadProcess(url: downloadFileURLString)
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
        
        //set standard ourput pipe
        let outputPipe = Pipe()
        currentDownloadProcess.standardOutput = outputPipe
        outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        
        //observer output changes
        var outputNotificationObserver: NSObjectProtocol?
        outputNotificationObserver = NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable, object: outputPipe.fileHandleForReading, queue: downloadQueue) { [unowned self] (notification) in
            //Start waitinng for next output stream
            DispatchQueue.main.async {
                outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
            }
            
            //Get current output stream data
            let outputData = outputPipe.fileHandleForReading.availableData
            
            //If there is some output data means process is running
            if outputData.count > 0, let outputString = String.init(data: outputData, encoding: .utf8) {
                //update progress
                let parsedOutputString = Aria2cParser.parse(string: outputString)
                if (!parsedOutputString.isEmpty) {
                    currentDownloadProcess.progress = DownloadProgress(fileName: fullFileName, output: parsedOutputString)
                    print(currentDownloadProcess.progress.debugDescription)
                }
                
                //trigger output stream update
                DispatchQueue.main.async {
                    self.delegate?.outputStream(output: parsedOutputString)
                }
            } else if let notificationObserver = outputNotificationObserver {
                //update progress
                currentDownloadProcess.progress = DownloadProgress(fileName: fullFileName, output: "", isFinish: true)
                
                //trigger download finish
                DispatchQueue.main.async {
                    self.delegate?.downloadFinish(url: downloadFileURLString)
                }
                
                //terminate current download process and remove process output observer
                currentDownloadProcess.terminate()
                NotificationCenter.default.removeObserver(notificationObserver)
            }
        }
        
        //set standard error pipe
        let errorPipe = Pipe()
        currentDownloadProcess.standardError = errorPipe
        errorPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        
        var errorNotificationObserver: NSObjectProtocol?
        errorNotificationObserver = NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable, object: errorPipe, queue: downloadQueue, using: { (notification) in
            //Start waitinng for next output stream
            DispatchQueue.main.async {
                errorPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
            }
            
            //Get current output stream data
            let errorData = outputPipe.fileHandleForReading.availableData
            
            //If there is some output data means process is running
            if errorData.count > 0, let outputString = String.init(data: errorData, encoding: .utf8) {
                //update progress
                let parsedOutputString = Aria2cParser.parse(string: outputString)
                if (!parsedOutputString.isEmpty) {
                    currentDownloadProcess.progress = DownloadProgress(fileName: fullFileName, output: parsedOutputString)
                    print(currentDownloadProcess.progress.debugDescription)
                }
                
                //trigger output stream update
                DispatchQueue.main.async {
                    self.delegate?.outputStream(output: parsedOutputString)
                }
            } else if let notificationObserver = errorNotificationObserver {
                //update progress
                currentDownloadProcess.progress = DownloadProgress(fileName: fullFileName, output: "", isFinish: true)
                
                //trigger download finish
                DispatchQueue.main.async {
                    self.delegate?.downloadFinish(url: downloadFileURLString)
                }
                
                //terminate current download process and remove process output observer
                currentDownloadProcess.terminate()
                NotificationCenter.default.removeObserver(notificationObserver)
            }
        }) 
        
        //launch download process
        currentDownloadProcess.launch()
        
        //trigger downnload start
        self.delegate?.downloadStart(url: downloadFileURLString)
    }
}
