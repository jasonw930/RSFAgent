//
//  TouchpadWindow.swift
//  RSFAgent
//
//  Created by Jason Wang on 2021-08-17.
//  Copyright © 2021 Redstone_Flash. All rights reserved.
//

import Cocoa
import AudioToolbox

class TrackpadWindow: Window {
    
    let width: CGFloat = 200
    let height: CGFloat = 120
    let font = NSFont.init(name: "Helvetica Neue", size: 30)
    
    let textMode = NSTextField()
    let elementMode = Element()
    var absolute = false
    
    func show() {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        
        let controller = NSWindowController(window: self)
        controller.showWindow(self)
        self.setFrameOrigin(NSPoint(x: 1440 - appDelegate.toolbarWindow.width - width, y: 60 + (660 - height)))
    }
    
    init() {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        super.init(contentRect: NSMakeRect(1440 - appDelegate.toolbarWindow.width - width, 60 + (660 - height), width, height),
                   styleMask: [.titled, .fullSizeContentView], backing: .buffered, defer: false);
        
        self.alphaValue = 0
        
        setupWindow()
        
        textMode.backgroundColor = backgroundColor
        textMode.isBordered = false
        textMode.textColor = NSColor.white
        textMode.font = font
        textMode.alignment = NSTextAlignment.center
        textMode.isBezeled = false
        textMode.isEditable = false
        textMode.setFrameSize(NSSize(width: width - 20, height: height - 50))
        textMode.setFrameOrigin(NSPoint(x: 10, y: 10))
        textMode.stringValue = "Relative"
        self.contentView?.addSubview(textMode)
        
        elementMode.setFrameOrigin(NSPoint(x: (width - elementMode.frame.width) / 2, y: height - 20))
        elementMode.left = {
            Element.enterWindow(appDelegate.trackpadBoundsWindow)
            return self.elementMode.switchToElement(appDelegate.trackpadBoundsWindow.elementTitle)
        }
        elementMode.right = {
            Element.exitWindow(from: self, to: appDelegate.toolbarWindow)
            return self.elementMode.switchToElement(appDelegate.toolbarWindow.elementTrackpad)
        }
        elementMode.up = {
            self.absolute = !self.absolute
            self.textMode.stringValue = self.absolute ? "Absolute" : "Relative"
            return self.elementMode
        }
        elementMode.down = elementMode.up
        self.contentView?.addSubview(elementMode)
    }
    
}
