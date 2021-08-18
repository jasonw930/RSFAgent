//
//  TrackpadBoundsWindow.swift
//  RSFAgent
//
//  Created by Jason Wang on 2021-08-18.
//  Copyright © 2021 Redstone_Flash. All rights reserved.
//


import Cocoa
import AudioToolbox

class TrackpadBoundsWindow: Window {
    
    let width: CGFloat = 80
    let height: CGFloat = 120
    let font = NSFont.init(name: "Helvetica Neue", size: 12)
    
    let textTitle = NSTextField()
    let elementTitle = Element()
    let textBounds = [NSTextField(), NSTextField(), NSTextField(), NSTextField()]
    let elementBounds = [Element(), Element(), Element(), Element()]
    var bounds = [0.0, 1.0, 0.0, 1.0]
    
    func show() {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        
        let controller = NSWindowController(window: self)
        controller.showWindow(self)
        self.setFrameOrigin(NSPoint(x: 1440 - appDelegate.toolbarWindow.width - appDelegate.trackpadWindow.width - width, y: 60 + (660 - height)))
    }
    
    init() {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        super.init(contentRect: NSMakeRect(1440 - appDelegate.toolbarWindow.width - width, 60 + (660 - height), width, height),
                   styleMask: [.titled, .fullSizeContentView], backing: .buffered, defer: false);
        
        self.alphaValue = 0
        
        setupWindow()
        
        textTitle.backgroundColor = backgroundColor
        textTitle.isBordered = false
        textTitle.textColor = NSColor.white
        textTitle.font = font
        textTitle.alignment = NSTextAlignment.left
        textTitle.isBezeled = false
        textTitle.isEditable = false
        textTitle.setFrameSize(NSSize(width: width - 30, height: 20))
        textTitle.setFrameOrigin(NSPoint(x: 20, y: 96))
        textTitle.stringValue = "Bounds"
        self.contentView?.addSubview(textTitle)
        
        elementTitle.setFrameOrigin(NSPoint(x: 9, y: 102))
        elementTitle.right = {
            Element.exitWindow(from: self, to: appDelegate.trackpadWindow)
            return self.elementTitle.switchToElement(appDelegate.trackpadWindow.elementMode)
        }
        elementTitle.down = {return self.elementTitle.switchToElement(appDelegate.trackpadBoundsWindow.elementBounds[0])}
        self.contentView?.addSubview(elementTitle)
        
        for i in 0...3 {
            textBounds[i].backgroundColor = backgroundColor
            textBounds[i].isBordered = false
            textBounds[i].textColor = NSColor.white
            textBounds[i].font = font
            textBounds[i].alignment = NSTextAlignment.left
            textBounds[i].isBezeled = false
            textBounds[i].isEditable = false
            textBounds[i].setFrameSize(NSSize(width: width - 30, height: 20))
            textBounds[i].setFrameOrigin(NSPoint(x: 20, y: 74 - 22 * i))
            textBounds[i].stringValue = "\(bounds[i])"
            self.contentView?.addSubview(textBounds[i])
            
            elementBounds[i].setFrameOrigin(NSPoint(x: 9, y: 80 - 22 * i))
            self.contentView?.addSubview(elementBounds[i])
        }
        
        elementBounds[0].up = {return self.elementBounds[0].switchToElement(appDelegate.trackpadBoundsWindow.elementTitle)}
        elementBounds[0].down = {return self.elementBounds[0].switchToElement(appDelegate.trackpadBoundsWindow.elementBounds[1])}
        elementBounds[0].left = {
            self.bounds[0] = max(0, self.bounds[0] - 0.1)
            self.textBounds[0].stringValue = String(format: "%.1f", self.bounds[0])
            return self.elementBounds[0]
        }
        elementBounds[0].right = {
            self.bounds[0] = min(1, self.bounds[0] + 0.1)
            self.textBounds[0].stringValue = String(format: "%.1f", self.bounds[0])
            return self.elementBounds[0]
        }
        elementBounds[1].up = {return self.elementBounds[1].switchToElement(appDelegate.trackpadBoundsWindow.elementBounds[0])}
        elementBounds[1].down = {return self.elementBounds[1].switchToElement(appDelegate.trackpadBoundsWindow.elementBounds[2])}
        elementBounds[1].left = {
            self.bounds[1] = max(0, self.bounds[1] - 0.1)
            self.textBounds[1].stringValue = String(format: "%.1f", self.bounds[1])
            return self.elementBounds[1]
        }
        elementBounds[1].right = {
            self.bounds[1] = min(1, self.bounds[1] + 0.1)
            self.textBounds[1].stringValue = String(format: "%.1f", self.bounds[1])
            return self.elementBounds[1]
        }
        elementBounds[2].up = {return self.elementBounds[2].switchToElement(appDelegate.trackpadBoundsWindow.elementBounds[1])}
        elementBounds[2].down = {return self.elementBounds[2].switchToElement(appDelegate.trackpadBoundsWindow.elementBounds[3])}
        elementBounds[2].left = {
            self.bounds[2] = max(0, self.bounds[2] - 0.1)
            self.textBounds[2].stringValue = String(format: "%.1f", self.bounds[2])
            return self.elementBounds[2]
        }
        elementBounds[2].right = {
            self.bounds[2] = min(1, self.bounds[2] + 0.1)
            self.textBounds[2].stringValue = String(format: "%.1f", self.bounds[2])
            return self.elementBounds[2]
        }
        elementBounds[3].up = {return self.elementBounds[3].switchToElement(appDelegate.trackpadBoundsWindow.elementBounds[2])}
        elementBounds[3].left = {
            self.bounds[3] = max(0, self.bounds[3] - 0.1)
            self.textBounds[3].stringValue = String(format: "%.1f", self.bounds[3])
            return self.elementBounds[3]
        }
        elementBounds[3].right = {
            self.bounds[3] = min(1, self.bounds[3] + 0.1)
            self.textBounds[3].stringValue = String(format: "%.1f", self.bounds[3])
            return self.elementBounds[3]
        }
        
    }
    
}
