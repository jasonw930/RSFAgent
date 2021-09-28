//
//  OLogWindow.swift
//  RSFAgent
//
//  Created by Jason Wang on 2021-09-27.
//  Copyright © 2021 Redstone_Flash. All rights reserved.
//

import Cocoa
import AudioToolbox

class OLogBehaviourWindow: Window {
    
    let width: CGFloat = 200
    let height: CGFloat = 80
    let font = NSFont.init(name: "Helvetica Neue", size: 30)
    
    let textBehaviour = NSTextField()
    let elementBehaviour = Element()
    var curBehaviour = 0
    let behaviour = ["List", "Test 1", "Test 2"]
    
    func show() {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        
        let controller = NSWindowController(window: self)
        controller.showWindow(self)
        self.setFrameOrigin(NSPoint(x: 1440 - appDelegate.toolbarWindow.width - width, y: 60 + (600 - height)))
    }
    
    init() {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        super.init(contentRect: NSMakeRect(1440 - appDelegate.toolbarWindow.width - width, 60 + (600 - height), width, height),
                   styleMask: [.titled, .fullSizeContentView], backing: .buffered, defer: false);
        
        self.alphaValue = 0
        
        setupWindow()
        
        textBehaviour.backgroundColor = backgroundColor
        textBehaviour.isBordered = false
        textBehaviour.textColor = NSColor.white
        textBehaviour.font = font
        textBehaviour.alignment = NSTextAlignment.center
        textBehaviour.isBezeled = false
        textBehaviour.isEditable = false
        textBehaviour.setFrameSize(NSSize(width: width - 20, height: height - 35))
        textBehaviour.setFrameOrigin(NSPoint(x: 10, y: 10))
        textBehaviour.stringValue = behaviour[curBehaviour]
        self.contentView?.addSubview(textBehaviour)
        
        elementBehaviour.setFrameOrigin(NSPoint(x: (width - elementBehaviour.frame.width) / 2, y: height - 20))
        elementBehaviour.left = {
            Element.enterWindow(appDelegate.oLogTriggerWindow)
            return self.elementBehaviour.switchToElement(appDelegate.oLogTriggerWindow.elementTrigger)
        }
        elementBehaviour.right = {
            Element.exitWindow(from: self, to: appDelegate.toolbarWindow)
            return self.elementBehaviour.switchToElement(appDelegate.toolbarWindow.elementOLog)
        }
        elementBehaviour.up = {
            self.curBehaviour -= 1
            if self.curBehaviour < 0 {
                self.curBehaviour = self.behaviour.count - 1
            }
            appDelegate.oLogTriggerWindow.curTrigger = 0
            appDelegate.oLogTriggerWindow.textTrigger.stringValue = appDelegate.oLogTriggerWindow.trigger[self.curBehaviour][0]
            self.textBehaviour.stringValue = self.behaviour[self.curBehaviour]
            return self.elementBehaviour
        }
        elementBehaviour.down = {
            self.curBehaviour += 1
            if self.curBehaviour >= self.behaviour.count {
                self.curBehaviour = 0
            }
            appDelegate.oLogTriggerWindow.curTrigger = 0
            appDelegate.oLogTriggerWindow.textTrigger.stringValue = appDelegate.oLogTriggerWindow.trigger[self.curBehaviour][0]
            self.textBehaviour.stringValue = self.behaviour[self.curBehaviour]
            return self.elementBehaviour
        }
        self.contentView?.addSubview(elementBehaviour)
    }
    
}
