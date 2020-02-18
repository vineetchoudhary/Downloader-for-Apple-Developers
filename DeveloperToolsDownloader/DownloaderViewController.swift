//
//  ViewController.swift
//  DeveloperToolsDownloader
//
//  Created by Vineet Choudhary on 17/02/20.
//  Copyright © 2020 Developer Insider. All rights reserved.
//

import Cocoa
import WebKit

class DownloaderViewController: NSViewController {

    //MARK: - Constants
    private let downloadAuthCookieName = "ADCDownloadAuth"
    private let developerToolsDownloadURL = "https://developer.apple.com/download/more/";
    private let supportedExtension = ["xip", "dmg", "zip", "pdf", "pkg"]
    private let downloadCompleteText = "download completed"
    
    //MARK: - Properties
    private var downloadAuthToken: String?
    private var downloadProcesses = [String: Process]()
    
    //MARK: - IBOutlets
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet var textView: NSTextView!
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let url = URL(string: developerToolsDownloadURL) else {
            print("Invalid URL")
            return
        }
        webView.navigationDelegate = self
        webView.load(URLRequest(url: url))
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

//MARK: - Download Helper
extension DownloaderViewController {
    fileprivate func startDownload(fileURL: String?) {
        guard let downloadAuthToken = downloadAuthToken else {
            updateTextView(text: "Download authentication token not found.\n")
            return
        }
        guard var downloadFileURL = fileURL else {
            updateTextView(text: "Download url not found.\n")
            return
        }
        
        //create or use existing download process
        var currentDownloadProcess: Process!
        currentDownloadProcess = downloadProcesses[downloadFileURL]
        if currentDownloadProcess == nil {
            currentDownloadProcess = Process()
            downloadProcesses[downloadFileURL] = currentDownloadProcess
        }
        
        if currentDownloadProcess.isRunning {
            updateTextView(text: "Please wait. Download in progress....\n")
            return
        }
        
        //use http protocol instead of https
        downloadFileURL = downloadFileURL.replacingOccurrences(of: "https://", with: "http://")

        let launchPath = Bundle.main.path(forResource: "Download", ofType: "sh")
        let aria2c = Bundle.main.path(forResource: "aria2c", ofType: nil)!
        currentDownloadProcess.launchPath = launchPath
        currentDownloadProcess.arguments = [downloadFileURL, downloadAuthToken, aria2c]
        
        let outputPipe = Pipe()
        currentDownloadProcess.standardOutput = outputPipe
        currentDownloadProcess.standardError = outputPipe
        outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        
        var notificationObserver: NSObjectProtocol?
        notificationObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outputPipe.fileHandleForReading, queue: .main) { [unowned self] (notification) in
            let outputData = outputPipe.fileHandleForReading.availableData
            if outputData.count > 0, let outputString = String.init(data: outputData, encoding: .utf8) {
                self.updateTextView(text: outputString)
                outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
            } else if let notificationObserver = notificationObserver {
                currentDownloadProcess.terminate()
                self.downloadProcesses.removeValue(forKey: downloadFileURL)
                NotificationCenter.default.removeObserver(notificationObserver)
            }
        }
        
        currentDownloadProcess.launch()
    }
    
    fileprivate func updateTextView(text: String) {
        textView.string.append(text)
        textView.scrollToEndOfDocument(nil)
    }
}

//MARK: - WebKit Navigation Delegate
extension DownloaderViewController : WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let pathExtension = navigationAction.request.url?.pathExtension,
            supportedExtension.contains(pathExtension){
            let downloadFileURL = navigationAction.request.url?.absoluteString
            self.startDownload(fileURL: downloadFileURL)
            decisionHandler(.cancel)
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        updateTextView(text: "\(error.localizedDescription)\n")
    }

    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let currentURL = webView.url?.absoluteString, currentURL == developerToolsDownloadURL {
            webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { [unowned self] (cookie) in
                self.downloadAuthToken = cookie.first(where: {$0.name == self.downloadAuthCookieName})?.value
                self.updateTextView(text: "Download authentication token - OK\n")
            }
        }
    }

    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        updateTextView(text: "\(error.localizedDescription)\n")
    }
}


