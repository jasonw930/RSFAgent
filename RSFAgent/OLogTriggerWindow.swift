//
//  OLogTriggerWindow.swift
//  RSFAgent
//
//  Created by Jason Wang on 2021-09-27.
//  Copyright © 2021 Redstone_Flash. All rights reserved.
//

import Cocoa
import AudioToolbox

class OLogTriggerWindow: Window {
    
    let width: CGFloat = 200
    let height: CGFloat = 80
    let font = NSFont.init(name: "Helvetica Neue", size: 24)
    
    let textTrigger = NSTextField()
    let elementTrigger = Element()
    var curTrigger = 0
    let trigger = [["About to rest", "Spontaneous", "Still in mind"], ["None 1"], ["None 2"]]
    
    func show() {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        
        let controller = NSWindowController(window: self)
        controller.showWindow(self)
        self.setFrameOrigin(NSPoint(x: 1440 - appDelegate.toolbarWindow.width - appDelegate.oLogBehaviourWindow.width - width, y: 60 + (600 - height)))
    }
    
    init() {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        super.init(contentRect: NSMakeRect(1440 - appDelegate.toolbarWindow.width - appDelegate.oLogBehaviourWindow.width - width, 60 + (600 - height), width, height),
                   styleMask: [.titled, .fullSizeContentView], backing: .buffered, defer: false);
        
        self.alphaValue = 0
        
        setupWindow()
        
        textTrigger.backgroundColor = backgroundColor
        textTrigger.isBordered = false
        textTrigger.textColor = NSColor.white
        textTrigger.font = font
        textTrigger.alignment = NSTextAlignment.center
        textTrigger.isBezeled = false
        textTrigger.isEditable = false
        textTrigger.setFrameSize(NSSize(width: width - 20, height: height - 35))
        textTrigger.setFrameOrigin(NSPoint(x: 10, y: 10))
        textTrigger.stringValue = trigger[appDelegate.oLogBehaviourWindow.curBehaviour][curTrigger]
        self.contentView?.addSubview(textTrigger)
        
        elementTrigger.setFrameOrigin(NSPoint(x: (width - elementTrigger.frame.width) / 2, y: height - 20))
        elementTrigger.left = {
            Element.enterWindow(appDelegate.oLogSaveWindow)
            return self.elementTrigger.switchToElement(appDelegate.oLogSaveWindow.elementSave)
        }
        elementTrigger.right = {
            Element.exitWindow(from: self, to: appDelegate.oLogBehaviourWindow)
            return self.elementTrigger.switchToElement(appDelegate.oLogBehaviourWindow.elementBehaviour)
        }
        elementTrigger.up = {
            self.curTrigger -= 1
            if self.curTrigger < 0 {
                self.curTrigger = self.trigger[appDelegate.oLogBehaviourWindow.curBehaviour].count - 1
            }
            self.textTrigger.stringValue = self.trigger[appDelegate.oLogBehaviourWindow.curBehaviour][self.curTrigger]
            return self.elementTrigger
        }
        elementTrigger.down = {
            self.curTrigger += 1
            if self.curTrigger >= self.trigger[appDelegate.oLogBehaviourWindow.curBehaviour].count {
                self.curTrigger = 0
            }
            self.textTrigger.stringValue = self.trigger[appDelegate.oLogBehaviourWindow.curBehaviour][self.curTrigger]
            return self.elementTrigger
        }
        self.contentView?.addSubview(elementTrigger)
    }
    
}
