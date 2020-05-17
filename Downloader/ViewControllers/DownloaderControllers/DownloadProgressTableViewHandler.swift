//
//  DownloadProgressTableViewHandler.swift
//  Downloader
//
//  Created by Vineet Choudhary on 17/05/20.
//  Copyright © 2020 Developer Insider. All rights reserved.
//

import Foundation
import Cocoa

class DownloadProgressTableViewHandler: NSObject {
    init(tableView: NSTableView) {
        super.init()
        tableView.delegate = self;
        tableView.dataSource = self;
    }
}

extension DownloadProgressTableViewHandler: NSTableViewDataSource {
    
}

extension DownloadProgressTableViewHandler: NSTableViewDelegate {
    
}
