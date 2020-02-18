//
//  LogsViewController.swift
//  Downloader for Apple Developers
//
//  Created by Vineet Choudhary on 18/02/20.
//  Copyright © 2020 Developer Insider. All rights reserved.
//

import Cocoa

class LogsViewController: NSViewController {

    var initialLogs: String?
    private var outputStreamObserver: NSObjectProtocol?
    
    @IBOutlet var textView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.string.append(initialLogs ?? "")
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        outputStreamObserver = NotificationCenter.default.addObserver(forName: .DownloadOutputStream, object: nil, queue: .main) { [unowned self] (notification) in
            guard let output = notification.object as? String else {
                return
            }
            self.textView.string.append(output)
            self.textView.scrollToEndOfDocument(nil)
        }
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        guard let outputStreamObserver = outputStreamObserver else {
            return
        }
        NotificationCenter.default.removeObserver(outputStreamObserver)
    }
    
    @IBAction func closeButtonAction(_ sender: NSButton) {
        dismiss(nil)
    }
    
    @IBAction func copyToClipboardButtonAction(_ sender: NSButton) {
        NSPasteboard.general.setString(textView.string, forType: .string)
    }
}
