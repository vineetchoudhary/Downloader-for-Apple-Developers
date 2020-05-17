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
    
    //MARK: - IBOutlets
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var downloadServicesTableView: NSTableView!
    @IBOutlet weak var downloadProgressTableView: NSTableView!
    
    //MARK: - Properties
    var downloadServiceTableViewHandler: DownloadServiceTableViewHandler!
    var downloadProgressTableViewHandler: DownloadProgressTableViewHandler!
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        //Download Service TableView
        downloadServiceTableViewHandler = DownloadServiceTableViewHandler(tableView: downloadServicesTableView)
        downloadServiceTableViewHandler.selectionChange { [weak self] (downloadURL) in
            guard let self = self else {
                return;
            }
            let url = URL(string: downloadURL.rawValue)!
            self.webView.navigationDelegate = self
            self.webView.load(URLRequest(url: url))
            self.updateStatus(text: NSLocalizedString("InitialStatus", comment: ""))
        }
        
        downloadProgressTableViewHandler = DownloadProgressTableViewHandler(tableView: downloadProgressTableView)
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
            let _ = SupportedExtension(rawValue: pathExtension) {
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
        if let currentURL = webView.url?.absoluteString,
            currentURL.lowercased().contains(DownloadURL.tools.rawValue.lowercased()) {
            self.updateStatus(text: NSLocalizedString("CheckingDownloadAuthToken", comment: ""))
            DispatchQueue.main.asyncAfter(deadline: .now()+4) {
                webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { [unowned self] (cookie) in
                    if let downloadAuthToken = cookie.first(where: {$0.name == CookieName.DownloadAuthToken.rawValue})?.value {
                        DownloadProcessManager.shared.setDownloadAuthToken(token: downloadAuthToken)
                        self.updateStatus(text: NSLocalizedString("DownloadAuthTokenSuccess", comment: ""))
                    } else {
                        self.updateStatus(text: NSLocalizedString("DownloadAuthTokenNotFound", comment: ""))
                    }
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        updateStatus(text: error.localizedDescription)
    }
}
