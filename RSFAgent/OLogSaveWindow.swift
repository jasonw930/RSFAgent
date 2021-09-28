//
//  OLogSaveWindow.swift
//  RSFAgent
//
//  Created by Jason Wang on 2021-09-28.
//  Copyright © 2021 Redstone_Flash. All rights reserved.
//

import Cocoa
import AudioToolbox

class OLogSaveWindow: Window {
    
    let width: CGFloat = 10
    let height: CGFloat = 80
    
    let elementSave = Element()
    
    func show() {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        
        let controller = NSWindowController(window: self)
        controller.showWindow(self)
        self.setFrameOrigin(NSPoint(x: 1440 - appDelegate.toolbarWindow.width - appDelegate.oLogBehaviourWindow.width - appDelegate.oLogTriggerWindow.width - width, y: 60 + (600 - height)))
    }
    
    init() {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        super.init(contentRect: NSMakeRect(1440 - appDelegate.toolbarWindow.width - appDelegate.oLogBehaviourWindow.width - appDelegate.oLogTriggerWindow.width - width, 60 + (600 - height), width, height),
                   styleMask: [.titled, .fullSizeContentView], backing: .buffered, defer: false);
        
        self.alphaValue = 0
        
        setupWindow()
        self.backgroundColor = NSColor.green
        
        elementSave.setFrameOrigin(NSPoint(x: (width - elementSave.frame.width) / 2, y: height - 20))
        elementSave.left = {
            let date = Date()
            let fileName = "olog_" + date.description.split(separator: " ")[0] + ".csv"
            let line = "\(Int64((date.timeIntervalSince1970 * 1000.0).rounded())),\(appDelegate.oLogBehaviourWindow.behaviour[appDelegate.oLogBehaviourWindow.curBehaviour]),\(appDelegate.oLogTriggerWindow.trigger[appDelegate.oLogBehaviourWindow.curBehaviour][appDelegate.oLogTriggerWindow.curTrigger])"
//            print(fileName)
//            print(line)

            let dir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last! as URL
            let url = dir.appendingPathComponent("ocd_log/" + fileName)
            do {
                try line.appendLineToURL(fileURL: url as URL)
                print("Logged")
            } catch {
                print("Could not write to file")
            }
            
            Element.exitWindows(from: [appDelegate.oLogBehaviourWindow, appDelegate.oLogTriggerWindow, appDelegate.oLogSaveWindow], to: appDelegate.toolbarWindow)
            return self.elementSave.switchToElement(appDelegate.toolbarWindow.elementOLog)
        }
        elementSave.right = {
            Element.exitWindow(from: self, to: appDelegate.oLogTriggerWindow)
            return self.elementSave.switchToElement(appDelegate.oLogTriggerWindow.elementTrigger)
        }
        self.contentView?.addSubview(elementSave)
    }
    
}

extension String {
    func appendLineToURL(fileURL: URL) throws {
        try (self + "\n").appendToURL(fileURL: fileURL)
    }
    
    func appendToURL(fileURL: URL) throws {
        let data = self.data(using: String.Encoding.utf8)!
        try data.append(fileURL: fileURL)
    }
}

extension Data {
    func append(fileURL: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        }
        else {
            try write(to: fileURL, options: .atomic)
        }
    }
}
