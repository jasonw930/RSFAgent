//
//  Element.swift
//  RSFAgent
//
//  Created by Jason Wang on 2021-07-08.
//  Copyright © 2021 Redstone_Flash. All rights reserved.
//

import Cocoa

class Element: NSView {

    var selected = false
    let backgroundColor = NSColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
    
    var left: (() -> Element)!
    var right: (() -> Element)!
    var up: (() -> Element)!
    var down: (() -> Element)!
    
    init() {
        super.init(frame: NSMakeRect(0, 0, 6, 6))
        
        left = {return self}
        right = {return self}
        up = {return self}
        down = {return self}
        
        self.alphaValue = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func switchToElement(_ element: Element) -> Element {
        selected = false
        alphaValue = 1
        animator().alphaValue = 0
        
        element.selected = true
        element.alphaValue = 0
        element.animator().alphaValue = 1
        
        return element
    }
    
    static func enterWindow(_ window: Window) {
        window.alphaValue = 0
        window.animator().alphaValue = 1
        window.open = true
        window.makeKey()
    }
    
    static func exitWindow(from: Window, to: Window) {
        from.alphaValue = 1
        from.animator().alphaValue = 0
        from.open = false
        to.makeKey()
    }
    
    static func exitWindows(from: [Window], to: Window) {
        for w in from {
            w.alphaValue = 1
            w.animator().alphaValue = 0
            w.open = false
        }
        to.makeKey()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        NSColor.clear.setFill()
        dirtyRect.fill()
        
        NSColor.green.setFill()
        NSBezierPath(ovalIn: dirtyRect).fill()
    }
    
}
