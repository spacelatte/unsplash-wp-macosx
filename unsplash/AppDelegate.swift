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
class AppDelegate: NSObject, NSApplicationDelegate, NSURLDownloadDelegate, NSMenuDelegate {

	@IBOutlet weak var window: NSWindow!

	var int: Int?
	var url: URL?
	var timer: Timer?
	var directory: String?

	func applicationDidBecomeActive(_ notification: Notification) {
		window.setIsVisible(true)
	}

	func applicationDidChangeOcclusionState(_ notification: Notification) {
		print(notification.debugDescription)
	}

	func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
		let menu = NSMenu(title: "unsplash")
		menu.delegate = self
		menu.addItem(withTitle: "cycle", action: #selector(didTimerFired), keyEquivalent: "$C")
		menu.addItem(withTitle: "open", action: #selector(didSelectOpen), keyEquivalent: "$O")
		return menu
	}

	func applicationWillFinishLaunching(_ notification: Notification) {
		int = Bundle.main.infoDictionary?["FetchInterval"] as! Int
		url = URL(string: Bundle.main.infoDictionary?["ImageURL"] as! String)
		let defaults = UserDefaults()
		defaults.set(url, forKey: "target")
		defaults.set(int, forKey: "interval")
		print("url:", url?.absoluteString ?? "(nil)")
	}
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		timer = Timer.scheduledTimer(
			timeInterval: Double(int!),
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
		if let directory = directory {
			try? FileManager().removeItem(atPath: directory)
		}
		directory = NSTemporaryDirectory()
			.appending(Bundle.main.bundleIdentifier!)
			.appending(".\(Date().timeIntervalSinceReferenceDate)")
			.appending(".jpg")
		let frame = NSScreen.main()?.visibleFrame
		let downloader = NSURLDownload(
			request: URLRequest(
				url: url!.appendingPathComponent("/\(Int(frame!.width))x\(Int(frame!.height))"),
			    cachePolicy: .reloadRevalidatingCacheData,
			    timeoutInterval: 30.0
			),
			delegate: self
		)
		downloader.setDestination(directory!, allowOverwrite: true)
	}

	func download(_ download: NSURLDownload, willSend request: URLRequest, redirectResponse: URLResponse?) -> URLRequest? {
		print("redirect:", download, request, redirectResponse ?? "resp:nil")
		return request
	}

	func downloadDidBegin(_ download: NSURLDownload) {
		print("begun: ", download)
	}

	func downloadDidFinish(_ download: NSURLDownload) {
		print("finished: ", download)
		let ws = NSWorkspace.shared()
		let file = URL.init(fileURLWithPath: directory!)
		print(file.absoluteString)
		for screen in NSScreen.screens()! {
			try? ws.setDesktopImageURL(file, for: screen, options: [:])
			continue
		}
		print("opts:", ws.desktopImageOptions(for: NSScreen.main()!)?.values ?? "nil")
	}

	func didTimerFired() {
		print("didTimerFired")
		getImage()
		return
	}
	func didSelectOpen() {
		print("didSelectOpen:", directory ?? "nil")
		NSWorkspace.shared().openFile(directory!, withApplication: "Preview")
	}

}

