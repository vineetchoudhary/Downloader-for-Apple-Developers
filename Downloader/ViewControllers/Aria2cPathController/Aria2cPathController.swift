//
//  Aria2cPathController.swift
//  Downloader
//
//  Created by Vineet Choudhary on 07/03/23.
//  Copyright © 2023 Developer Insider. All rights reserved.
//

import AppKit

class Aria2cPathController: NSViewController {
	@IBOutlet weak var aria2cPath: NSTextField!

	@IBAction func aria2cPathSaveAction(_ sender: NSButtonCell) {
		self.dismiss(sender)
	}
}
