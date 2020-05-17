//
//  Configuration.swift
//  Downloader
//
//  Created by Vineet Choudhary on 17/05/20.
//  Copyright © 2020 Developer Insider. All rights reserved.
//

import Foundation

//MARK: - Constants
enum DownloadSource: String, CaseIterable {
    case tools, video
    
    var url: String {
        get {
            switch self {
            case .video:
                return "https://developer.apple.com/videos/"
            case .tools:
                return "https://developer.apple.com/download/more"
            }
        }
    }
    
    var title: String {
        get {
            switch self {
            case .video:
                return NSLocalizedString("WWDCVideos", comment: "")
            case .tools:
                return NSLocalizedString("DeveloperTools", comment: "")
            }
        }
    }
}

enum SupportedExtension: String {
    case xip, dmg, zip, pdf, pkg, mov, mp4, avi
    case unsupported
}

enum CookieName: String {
    case DownloadAuthToken = "ADCDownloadAuth"
}
