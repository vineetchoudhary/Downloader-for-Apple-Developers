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
    private(set) var outputNotificationObserver: NSObjectProtocol?
    
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
        guard let downloadFileURLString = fileURL,
              let downloadFileURL = URL(string: downloadFileURLString) else {
            let outputString = NSLocalizedString("DownloadURLNotFound", comment: "")
            delegate?.outputStream(output: outputString)
            return
        }
        
        let fileExtension = downloadFileURL.pathExtension
        let lastPathComponent = downloadFileURL.lastPathComponent
        let fileName = lastPathComponent.components(separatedBy: fileExtension).first!
        let fullFileName = fileName + fileExtension
        
        //        use http protocol instead of https
        //        downloadFileURLString = downloadFileURLString.replacingOccurrences(of: "https://", with: "http://")
        
        var launchPath: String
        var launchArguments = [String]()
        
        //Add aria2c path
        let aria2cPath = Bundle.main.path(forResource: "aria2c", ofType: nil)!
        launchArguments.append(aria2cPath)
        
        //Add download URL
        launchArguments.append(downloadFileURLString)
        
        //Set/Add Source Specific Variable/Arguments
        switch source {
        case .operatingSystems:
            launchPath = Bundle.main.path(forResource: "AppleOSDownload", ofType: "sh")!
        case .tools:
            launchPath = Bundle.main.path(forResource: "AppleMoreDownload", ofType: "sh")!
        case .video:
            launchPath = Bundle.main.path(forResource: "AppleVideoDownload", ofType: "sh")!
        }
        
        // If source is operating systems or tools, add download auth token to  launch arguments
        if source == .operatingSystems || source == .tools {
            guard let downloadAuthToken = downloadAuthToken else {
                let outputString = NSLocalizedString("DownloadAuthTokenNotFound", comment: "")
                delegate?.outputStream(output: outputString)
                return
            }
            launchArguments.append(downloadAuthToken)
        } else {
            let outputString = NSLocalizedString("DownloadNoTokenRequired", comment: "")
            delegate?.outputStream(output: outputString)
        }
        
        //create or use existing download process
        var currentDownloadProcess: DownloadProcess!
        currentDownloadProcess = downloadProcesses.first(where: { $0.url == downloadFileURLString })
        if currentDownloadProcess == nil {
            currentDownloadProcess = DownloadProcess(url: downloadFileURLString, fileName: fullFileName)
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
        currentDownloadProcess.standardError = outputPipe
        currentDownloadProcess.standardOutput = outputPipe
        outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        
        //observer output changes
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
                let parsedOutput = Aria2cParser.parse(string: outputString)
                if (parsedOutput.error?.count ?? 0) > 0 {
                    currentDownloadProcess.progress = DownloadProgress(fileName: fullFileName, output: parsedOutput, isFinish: true)
                    completeDownloadProcess(currentDownloadProcess, output: parsedOutput)
                    triggerOutputStream(parsedOutput)
                    return
                } else if (!parsedOutput.output.isEmpty) {
                    currentDownloadProcess.progress = DownloadProgress(fileName: fullFileName, output: parsedOutput)
                    print(currentDownloadProcess.progress.debugDescription)
                }
                
                triggerOutputStream(parsedOutput)
            } else {
                completeDownloadProcess(currentDownloadProcess, output: nil)
            }
        }
        
        //launch download process
        currentDownloadProcess.launch()
        
        //trigger downnload start
        triggerDownloadStart(downloadFileURLString)
    }
    
    func completeDownloadProcess(_ downloadProcess: DownloadProcess, output: Aria2cOutput?) {
        if let notificationObserver = outputNotificationObserver {
            //update progress
            let finalOutput = output ?? Aria2cOutput("", nil)
            downloadProcess.progress = DownloadProgress(fileName: downloadProcess.fileName, output: finalOutput, isFinish: true)
            
            //trigger download finish
            triggerDownloadFinish(downloadProcess.url)
            
            //terminate current download process and remove process output observer
            downloadProcess.terminate()
            NotificationCenter.default.removeObserver(notificationObserver)
        }
    }
}

//MARK: - Delegate trigger
extension DownloadProcessManager {
    func triggerDownloadStart(_ url: String) {
        DispatchQueue.main.async {
            self.delegate?.downloadStart(url: url)
        }
    }
    
    func triggerDownloadFinish(_ url: String) {
        DispatchQueue.main.async {
            self.delegate?.downloadFinish(url: url)
        }
    }
    
    func triggerOutputStream(_ output: Aria2cOutput) {
        //trigger output stream update
        DispatchQueue.main.async {
            let finalOutput = "\(output.output) - \(output.error ?? "")"
            self.delegate?.outputStream(output: finalOutput)
        }
    }
}
