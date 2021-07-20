//
//  TextWindow.swift
//  RSFAgent
//
//  Created by Jason Wang on 2021-07-08.
//  Copyright © 2021 Redstone_Flash. All rights reserved.
//

import Cocoa
import AudioToolbox

class TextWindow: Window {

    let width: CGFloat = 200
    let height: CGFloat = 300
    let font = NSFont.init(name: "Helvetica Neue", size: 30)
    let fontSmall = NSFont.init(name: "Menlo Regular", size: 12)
    
    let textText = NSTextField()
    let elementText = Element()
    
    let highlightColor = NSColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        
    var curPage = 0
    var pages = Array(repeating: NSText(), count: 10)
    
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
        for i in 0...pages.count-1 {
            pages[i] = NSText()
            pages[i].backgroundColor = backgroundColor
            pages[i].textColor = NSColor.white
            pages[i].font = fontSmall
            pages[i].alignment = NSTextAlignment.left
            pages[i].setFrameSize(NSSize(width: width - 15, height: height - 35)) // Frame size adjustment to match line wrap
            pages[i].setFrameOrigin(NSPoint(x: 10, y: 10))
            
            pages[i].insertText("abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz")
        }
        
        textText.backgroundColor = backgroundColor
        textText.isBordered = false
        textText.textColor = NSColor.white
        textText.font = fontSmall
        textText.alignment = NSTextAlignment.left
        textText.isBezeled = false
        textText.isEditable = false
        textText.setFrameSize(NSSize(width: width - 20, height: height - 35))
        textText.setFrameOrigin(NSPoint(x: 10, y: 10))
        self.contentView?.addSubview(textText)
        
        updateTextField()
        
        elementText.setFrameOrigin(NSPoint(x: (width - elementText.frame.width) / 2, y: height - 20))
        elementText.right = {
            Element.exitWindow(from: self, to: appDelegate.toolbarWindow)
            return self.elementText.switchToElement(appDelegate.toolbarWindow.elementText)
        }
        self.contentView?.addSubview(elementText)
    }
    
    func updateTextField() {
        let s = NSMutableAttributedString(string: pages[curPage].string + " ")
        s.addAttributes([.backgroundColor : highlightColor], range: NSMakeRange(pages[curPage].selectedRange.location, 1))
        textText.attributedStringValue = s
    }
    
}
