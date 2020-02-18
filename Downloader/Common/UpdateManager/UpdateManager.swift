//
//  UpdateManager.swift
//  Downloader
//
//  Created by Vineet Choudhary on 18/02/20.
//  Copyright © 2020 Developer Insider. All rights reserved.
//

import Foundation
import Cocoa

struct Release: Codable {
    let id: Int
    let url: String
    let name: String
    let body: String
    let htmlURL: String
    let tagName: String

    enum CodingKeys: String, CodingKey {
        case id
        case url
        case name
        case body
        case htmlURL = "html_url"
        case tagName = "tag_name"
    }
}

struct UpdateManager {
    let updateURL = "https://api.github.com/repos/vineetchoudhary/Downloader-for-Apple-Developers/releases/latest"
    static let shared = UpdateManager()
    private init() {
    }
    
    func checkForUpdates(updateAvailable: @escaping (String?) -> Void) {
        let session = URLSession(configuration: .default)
        let updateTask = session.dataTask(with: URL(string: updateURL)!) { (data, response, error) in
            DispatchQueue.main.async {
                guard let data = data else {
                    updateAvailable(nil)
                    return
                }
                guard let release = try? JSONDecoder().decode(Release.self, from: data) else {
                    updateAvailable(nil)
                    return
                }
                
                guard let infoPlist = Bundle.main.infoDictionary else {
                    updateAvailable(nil)
                    return
                }
                
                guard let installedVersion = infoPlist["CFBundleShortVersionString"] as? String else {
                    updateAvailable(nil)
                    return
                }
                
                guard let installedBuildNumber = infoPlist["CFBundleVersion"] as? String else {
                    updateAvailable(nil)
                    return
                }
                
                let installedVersionToCompare = "\(installedVersion).\(installedBuildNumber)"
                
                //Check Version and Build Number
                let result = (installedVersionToCompare.compare(release.tagName, options: .numeric) == .orderedAscending)
                if result {
                    updateAvailable(release.htmlURL)
                } else {
                    updateAvailable(nil)
                }
            }
        }
        updateTask.resume()
    }
}

extension UpdateManager {
    func showUpdateAlert(updateURL: String?) {
        guard let updateURL = updateURL,
            let updateHTMLURL = URL(string: updateURL) else {
            return
        }
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("UpdateMessage", comment: "")
        alert.informativeText = NSLocalizedString("UpdateInformativeText", comment: "")
        alert.addButton(withTitle: NSLocalizedString("Yes", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("No", comment: ""))
        alert.alertStyle = .informational
        if alert.runModal() == .alertFirstButtonReturn {
            NSWorkspace.shared.open(updateHTMLURL)
        }
    }
}
