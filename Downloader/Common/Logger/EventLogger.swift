//
//  EventLogger.swift
//  Downloader
//
//  Created by Vineet Choudhary on 18/05/20.
//  Copyright © 2020 Developer Insider. All rights reserved.
//

import Foundation
import AppCenterAnalytics

struct EventLogger {
    static func downloadStart(url: String) {
        let params = getParams(from: url)
        MSAnalytics.trackEvent("Download Start", withProperties: params)
    }
    
    static func downloadFinish(url: String) {
        let params = getParams(from: url)
        MSAnalytics.trackEvent("Download Finish", withProperties: params)
    }
    
    private static func getParams(from urlString: String)-> [String: String] {
        var params = [String: String]()
        guard let url = URL(string: urlString) else {
            params["full_url"] = urlString
            return params
        }
        
        params["full_url"] = url.absoluteString
        params["file_name"] = url.lastPathComponent
        return params;
    }
}
