//
//  DownloadProcessProtocol.swift
//  Downloader
//
//  Created by Vineet Choudhary on 18/05/20.
//  Copyright © 2020 Developer Insider. All rights reserved.
//

import Foundation

protocol DownloadProcessDelegate: class {
    func downloadStart(url: String)
    func downloadFinish(url: String)
    func outputStream(output: String)
}
