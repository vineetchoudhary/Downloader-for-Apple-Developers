//
//  Aria2cDownloader.swift
//  Downloader
//
//  Created by Vineet Choudhary on 25/02/23.
//  Copyright © 2023 Developer Insider. All rights reserved.
//

import Foundation

class Aria2cDownloader {

	static var aria2cLocalURL: URL? {
		guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("aria2c") else {
			return nil
		}

		return documentDirectory
	}

	static var aira2cLocalPath: String? {
		aria2cLocalURL?.absoluteString.replacingOccurrences(of: "file://", with: "")
	}

	var aria2cRemoteURL: URL {
		let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
		let path = "https://github.com/vineetchoudhary/Downloader-for-Apple-Developers/releases/download/\(version)/aria2c"
		return URL(string: path)!
	}

	func startDownload() {
		let fileManager = FileManager.default
		let request = URLRequest(url: aria2cRemoteURL)

		DLog.info("Downloading aria2c from \(aria2cRemoteURL.absoluteString)")
		let aria2cDownloadTask = URLSession.shared.downloadTask(with: request) { tempURL, _, error in
			guard let tempURL else {
				DLog.error("Unable to download aria2c. Error - \(String(describing: error))")
				return
			}

			guard let aria2cLocalURL = Self.aria2cLocalURL, let aira2cLocalPath = Self.aira2cLocalPath else {
				return
			}

			do {
				// remove existing aria2c
				if fileManager.fileExists(atPath: aira2cLocalPath) {
					try fileManager.removeItem(at: aria2cLocalURL)
					DLog.info("Removed existing aria2c.")
				}

				// move aria2c from temp location to document directory
				try fileManager.copyItem(at: tempURL, to: aria2cLocalURL)
				DLog.info("aria2c download at - \(aria2cLocalURL.absoluteString)")
			} catch {
				DLog.error("Unable to download aria2c. Error - \(error)")
			}
		}

		aria2cDownloadTask.resume()
	}
}
