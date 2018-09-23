//
//  AppDelegate.swift
//  IconHide
//
//  Created by Zeqiang on 2018/9/23.
//  Copyright © 2018年 Zeqiang. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    lazy var showAndHideItem : NSMenuItem = {
        return NSMenuItem(title: "Hide", action: #selector(AppDelegate.toggleDesktopIcons(_:)), keyEquivalent: "H")
    }()
    var didDesktopIconsShown = true
    
    fileprivate func setStatuItemImage() {
        let statusItemImageName = didDesktopIconsShown ? "StatusBarButtonShowImage" : "StatusBarButtonHideImage"
        
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name(statusItemImageName))
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        didDesktopIconsShown = getValueOfCreatDesktop()
        
        setStatuItemImage()
        constructMenu()
    }
    
    private func constructMenu() {
        let menu = NSMenu()
        
        menu.addItem(showAndHideItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        menu.delegate = self
        
        statusItem.menu = menu
    }
    
    @objc func toggleDesktopIcons(_ sender: Any?) {
        let command = "defaults write com.apple.finder CreateDesktop " + (!didDesktopIconsShown).toString() + ";killall Finder"
        
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]
        task.launch()
        
        didDesktopIconsShown.toggle()
        setStatuItemImage()
    }
    
    func getValueOfCreatDesktop() -> Bool {
        var output : [String] = []
        
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c","defaults read com.apple.finder CreateDesktop"]
        
        let outpipe = Pipe()
        task.standardOutput = outpipe;

        task.launch()
        
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            output = string.components(separatedBy: "\n")
        }
        return output[0].toBool() ?? false
    }
}

extension AppDelegate : NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        didDesktopIconsShown = getValueOfCreatDesktop()
        if didDesktopIconsShown {
            showAndHideItem.title = "Hide Icons"
            showAndHideItem.keyEquivalent = "H"
        } else {
            showAndHideItem.title = "Show Icons"
            showAndHideItem.keyEquivalent = "S"
        }
    }
}

extension String {
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
}

extension Bool {
    func toString() -> String{
        if self == true {
            return "true"
        } else {
            return "false"
        }
    }
}
