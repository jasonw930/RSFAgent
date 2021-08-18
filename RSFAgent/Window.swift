//
//  Window.swift
//  RSFAgent
//
//  Created by Jason Wang on 2021-07-19.
//  Copyright © 2021 Redstone_Flash. All rights reserved.
//

import Foundation

import Cocoa

class Window: NSWindow {

    var open = false
    
    func setupWindow() {
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
    }
    
}
