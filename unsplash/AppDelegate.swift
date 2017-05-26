//
//  AppDelegate.swift
//  unsplash
//
//  Created by Mert Akengin on 26/05/17.
//  Copyright © 2017 Mert Akengin. All rights reserved.
//

import Cocoa
import Carbon
import CoreImage
import os
import PreferencePanes
import SystemConfiguration


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSURLDownloadDelegate {

	@IBOutlet weak var window: NSWindow!

	var url: URL?
	var timer: Timer?
	var directory: String?

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		directory = NSTemporaryDirectory().appending(Bundle.main.bundleIdentifier!)
		print("path:", directory!)
		url = URL(string: Bundle.main.infoDictionary?["ImageURL"] as! String)
		print("url:", url)
		timer = Timer.scheduledTimer(
			timeInterval: 60.0,
			target: self,
			selector: #selector(didTimerFired),
			userInfo: nil,
			repeats: true
		)
		timer?.fire()
		print("timer:", timer!)
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		timer?.invalidate()
	}

	func getImage() {
		let downloader = NSURLDownload(request: URLRequest(url: url!), delegate: self)
		downloader.setDestination(directory!, allowOverwrite: true)
	}

	func download(_ download: NSURLDownload, willSend request: URLRequest, redirectResponse: URLResponse?) -> URLRequest? {
		print("redirect:", download, request, redirectResponse)
		return request
	}

	func downloadDidBegin(_ download: NSURLDownload) {
		print("begun: ", download)
	}

	func downloadDidFinish(_ download: NSURLDownload) {
		print("finished: ", download)
		let ws = NSWorkspace.shared()
		let file = URL.init(fileURLWithPath: directory!)
		for screen in NSScreen.screens()! {
			try? ws.setDesktopImageURL(file, for: screen, options: Dictionary.init())
			continue
		}
	}

	func didTimerFired() {
		print("didTimerFired")
		getImage()
		return
	}

}

