//
//  DownloadProcess.swift
//  Downloader
//
//  Created by Vineet Choudhary on 18/05/20.
//  Copyright © 2020 Developer Insider. All rights reserved.
//

import Foundation

class DownloadProcess: Process {
    var url: String!
    var lastOutput: String?
    
    init(url: String) {
        super.init()
        self.url = url
    }
}
