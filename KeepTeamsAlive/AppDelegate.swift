//
//  AppDelegate.swift
//  KeepTeamsAlive
//
//  Created by 庄黛淳华 on 2024/8/28.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

	var statusItem: NSStatusItem!

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		addStatusItem()
		monitorTeams()
	}

	func addStatusItem() {
		statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
		statusItem.button?.attributedTitle = NSAttributedString(string: "Teams", attributes: [
			.font: NSFont.systemFont(ofSize: 6)
		])

		let menu = NSMenu(title: "menu")
		statusItem.menu = menu

		let quit = NSMenuItem(title: "quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "")
		quit.target = NSApplication.shared
		menu.addItem(quit)
	}

	func monitorTeams() {
		let edgeTeamsURL = URL(filePath: ("~/Applications/Edge Apps.localized/Microsoft Teams.app" as NSString).expandingTildeInPath)

		Task {
			while true {
				let teamsIsRunning = NSWorkspace.shared.runningApplications.compactMap(\.localizedName).contains("Microsoft Teams")
				if !teamsIsRunning {
					await MainActor.run {
						let configuration = NSWorkspace.OpenConfiguration()
						configuration.hides = true
						configuration.activates = false
						configuration.promptsUserIfNeeded = false
						configuration.createsNewApplicationInstance = false
						NSWorkspace.shared.openApplication(at: edgeTeamsURL, configuration: configuration)
					}
				}
				try? await Task.sleep(for: .seconds(10))
			}
		}
	}
}

