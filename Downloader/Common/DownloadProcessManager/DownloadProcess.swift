//
//  DownloadProcess.swift
//  Downloader
//
//  Created by Vineet Choudhary on 18/05/20.
//  Copyright © 2020 Developer Insider. All rights reserved.
//

import Foundation

class DownloadProcess {
    //MARK: - private properties
    private let process: Process!
    
    //MARK: - public properties
    let url: String!
    var progress: DownloadProgress?
    
    //MARK: - computed properties
    var isRunning: Bool {
        return process.isRunning
    }
    
    var launchPath: String? {
        get { return process.launchPath }
        set { process.launchPath = newValue }
    }
    
    var arguments: [String]? {
        get { return process.arguments }
        set { process.arguments = newValue }
    }
    
    var standardOutput: Any? {
        get { return process.standardOutput }
        set { process.standardOutput = newValue }
    }
    
    var standardError: Any? {
        get { return process.standardError }
        set { process.standardError = newValue }
    }
    
    //MARK: - Init
    init(url: String) {
        self.url = url
        self.process = Process()
    }
    
    //MARK: - function
    func terminate() {
        process.terminate()
    }
    
    func launch() {
        process.launch()
    }
}
