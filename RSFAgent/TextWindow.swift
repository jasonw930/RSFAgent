//
//  TextWindow.swift
//  RSFAgent
//
//  Created by Jason Wang on 2021-07-08.
//  Copyright © 2021 Redstone_Flash. All rights reserved.
//

import Cocoa
import AudioToolbox

class TextWindow: NSWindow {

    let width: CGFloat = 200
    let height: CGFloat = 300
    let font = NSFont.init(name: "Helvetica Neue", size: 30)
    
    let textText = NSTextField()
    let elementText = Element()
    
    func show() {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        
        let controller = NSWindowController(window: self)
        controller.showWindow(self)
        self.setFrameOrigin(NSPoint(x: 1440 - appDelegate.toolbarWindow.width - width, y: 60 + (720 - height)))
    }
    
    init() {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        super.init(contentRect: NSMakeRect(1440 - appDelegate.toolbarWindow.width - width, 60 + (720 - height), width, height),
                   styleMask: [.titled, .fullSizeContentView], backing: .buffered, defer: false);
        
        self.alphaValue = 0
        
        
        // Removes the title bar
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        self.standardWindowButton(.closeButton)?.isHidden = true
        self.standardWindowButton(.miniaturizeButton)?.isHidden = true
        self.standardWindowButton(.zoomButton)?.isHidden = true
        
        // Set color, disable movable
        self.backgroundColor = NSColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        self.isMovable = false
        
        // Always on screen
        self.makeKey()
        self.collectionBehavior = [.canJoinAllSpaces]
                
        // Text
        elementText.setFrameOrigin(NSPoint(x: (width - elementText.frame.width) / 2, y: height - 20))
        elementText.right = {
            Element.exitWindow(from: self, to: appDelegate.toolbarWindow)
            return self.elementText.switchToElement(appDelegate.toolbarWindow.elementText)
        }
        self.contentView?.addSubview(elementText)
    }
    
}
