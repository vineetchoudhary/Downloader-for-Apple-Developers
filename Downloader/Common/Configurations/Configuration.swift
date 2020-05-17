//
//  Configuration.swift
//  Downloader
//
//  Created by Vineet Choudhary on 17/05/20.
//  Copyright © 2020 Developer Insider. All rights reserved.
//

import Foundation

//MARK: - Constants
enum DownloadURL: String {
    case video = "https://developer.apple.com/videos/"
    case tools = "https://developer.apple.com/download/more"
}

enum SupportedExtension: String {
    case xip, dmg, zip, pdf, pkg
    case unsupported
}

enum CookieName: String {
    case DownloadAuthToken = "ADCDownloadAuth"
}
