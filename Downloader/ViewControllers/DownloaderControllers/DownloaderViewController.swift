//
//  DownloaderViewController.swift
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
    
    //MARK: - IBOutlets
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var statusLabel: NSTextField!
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string: developerToolsDownloadURL)!
        webView.navigationDelegate = self
        webView.load(URLRequest(url: url))
        updateStatus(text: NSLocalizedString("InitialStatus", comment: ""))
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func statusTapAction(_ sender: NSClickGestureRecognizer) {
        performSegue(withIdentifier: "ShowLogsViewController", sender: nil)
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let logsViewController = segue.destinationController as? LogsViewController {
            logsViewController.initialLogs = DownloadProcessManager.shared.downloadLogs
        }
    }
    
}

//MARK: - Download Helper
extension DownloaderViewController {
    fileprivate func startDownload(fileURL: String?) {
        DownloadProcessManager.shared.startDownload(fileURL: fileURL) { (outputStream) in
            self.updateStatus(text: outputStream)
        }
    }
    
    fileprivate func updateStatus(text: String) {
        if !text.isEmpty {
            self.statusLabel.stringValue = text
        }
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
        updateStatus(text: error.localizedDescription)
    }

    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let currentURL = webView.url?.absoluteString, currentURL == developerToolsDownloadURL {
            webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { [unowned self] (cookie) in
                if let downloadAuthToken = cookie.first(where: {$0.name == self.downloadAuthCookieName})?.value {
                    DownloadProcessManager.shared.downloadAuthToken = downloadAuthToken
                    self.updateStatus(text: NSLocalizedString("DownloadAuthTokenSuccess", comment: ""))
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        updateStatus(text: error.localizedDescription)
    }
}


