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
    @IBOutlet weak var downloadSourceTableView: NSTableView!
    @IBOutlet weak var downloadProgressTableView: NSTableView!
    
    //MARK: - Properties
    private var downloadSource: DownloadSource = .tools
    private var downloadSourceTableViewHandler: DownloadSourceTableViewHandler!
    private var downloadProgressTableViewHandler: DownloadProgressTableViewHandler!
    private var downloadProcessManager = DownloadProcessManager.shared
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        //Download Service TableView
        downloadSourceTableViewHandler = DownloadSourceTableViewHandler(tableView: downloadSourceTableView)
        
        //Handle downnload service selection change
        downloadSourceTableViewHandler.selectionChange { [weak self] (downloadSource) in
            guard let self = self else {
                return;
            }
            //Set Download URL
            self.downloadSource = downloadSource;
            
            //Load Download URL to WebView
            let url = URL(string: downloadSource.url)!
            self.webView.navigationDelegate = self
            self.webView.load(URLRequest(url: url))
            
            let status = String(format: NSLocalizedString("SwitchingSource", comment: ""), downloadSource.title)
            DLog.info("Source Status - \(status)")
            self.updateStatus(text: status)
        }
        
        //Downnload Progress TableView
        downloadProgressTableViewHandler = DownloadProgressTableViewHandler(tableView: downloadProgressTableView)
        
        //Setup download process manager
        downloadProcessManager.delegate = self
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func statusTapAction(_ sender: NSClickGestureRecognizer) {
        performSegue(withIdentifier: "ShowLogsViewController", sender: nil)
    }
}

//MARK: - Download Helper
extension DownloaderViewController {
    fileprivate func startDownload(fileURL: String?) {
        downloadProcessManager.startDownload(source: downloadSource, fileURL: fileURL)
    }
    
    fileprivate func updateStatus(text: String) {
        if !text.isEmpty {
            self.statusLabel.stringValue = text
        }
    }
    
    fileprivate func checkDownloadAuthToken() {
        DispatchQueue.main.asyncAfter(deadline: .now()+4) { [weak self] in
            guard let self = self else {
                return;
            }
            
            self.webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { [unowned self] (cookie) in
                if let downloadAuthToken = cookie.first(where: {$0.name == CookieName.downloadAuthToken.rawValue})?.value {
                    DownloadProcessManager.shared.setDownloadAuthToken(token: downloadAuthToken)
                    let status = NSLocalizedString("DownloadAuthTokenSuccess", comment: "")
                    DLog.error("Status - \(status)")
                    self.updateStatus(text: status)
                } else {
                    let status = NSLocalizedString("DownloadAuthTokenNotFound", comment: "")
                    DLog.error("Status - \(status)")
                    self.updateStatus(text: status)
                }
            }
        }
    }
}

//MARK: - WebKit Navigation Delegate
extension DownloaderViewController : WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let pathExtension = navigationAction.request.url?.pathExtension.lowercased(),
            let _ = SupportedExtension(rawValue: pathExtension) {
            let downloadFileURL = navigationAction.request.url?.absoluteString
            DLog.info("Decided download for extension = - \(pathExtension)")
            self.startDownload(fileURL: downloadFileURL)
            decisionHandler(.cancel)
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        DLog.error("Navigation Error - \(error.localizedDescription)")
        updateStatus(text: error.localizedDescription)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let currentURL = webView.url?.absoluteString else {
            let status = NSLocalizedString("CommonError", comment: "")
            DLog.info("Navigation Status - \(status)")
            updateStatus(text: status)
            return;
        }
        if currentURL.lowercased().contains(AppleDomains.auth.rawValue.lowercased()) {
            let status = NSLocalizedString("LoginRequired", comment: "")
            DLog.info("Navigation Status - \(status)")
            updateStatus(text: status)
        } else if currentURL.lowercased().contains(DownloadSource.tools.url.lowercased()) {
            let status = NSLocalizedString("CheckingDownloadAuthToken", comment: "")
            DLog.info("Navigation Status - \(status)")
            updateStatus(text: status)
            checkDownloadAuthToken()
        } else {
            let status = NSLocalizedString("AllSet", comment: "")
            DLog.info("Navigation Status - \(status)")
            updateStatus(text: status)
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        DLog.error(error.localizedDescription)
        updateStatus(text: error.localizedDescription)
    }
}

//MARK: - DownloadProcessManager Delegate
extension DownloaderViewController: DownloadProcessDelegate {
    func downloadStart(url: String) {
        DLog.info("Download Started - \(url)")
        EventLogger.downloadStart(url: url)
    }
    
    func downloadFinish(url: String) {
        DLog.info("Download Finish - \(url)")
        EventLogger.downloadFinish(url: url)
        downloadProgressTableView.reloadData()
    }
    
    func outputStream(output: String) {
        DLog.info("Output Stream - \(output)")
        downloadProgressTableView.reloadData()
    }
}
