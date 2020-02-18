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
        DownloadProcessManager.shared.startDownload(fileURL: fileURL) { (outputStream) in
            self.updateTextView(text: outputStream)
        }
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
                let downloadAuthToken = cookie.first(where: {$0.name == self.downloadAuthCookieName})?.value
                DownloadProcessManager.shared.downloadAuthToken = downloadAuthToken
                self.updateTextView(text: "Download authentication token - OK\n")
            }
        }
    }

    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        updateTextView(text: "\(error.localizedDescription)\n")
    }
}


