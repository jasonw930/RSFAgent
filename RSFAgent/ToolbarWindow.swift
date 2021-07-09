//
//  ToolbarWindow.swift
//  RSFAgent
//
//  Created by Jason Wang on 2021-04-18.
//  Copyright © 2021 Redstone_Flash. All rights reserved.
//

import Cocoa
import AudioToolbox

class ToolbarWindow: NSWindow {

    var lastTime = NSDate.timeIntervalSinceReferenceDate
    
    let width: CGFloat = 50
    let height: CGFloat = 780
    let font = NSFont.init(name: "Helvetica Neue", size: 30)
    
    let textVolume = NSTextField()
    let elementVolume = Element()
    
    let textText = NSTextField()
    let elementText = Element()
    
    func show() {
        let controller = NSWindowController(window: self)
        controller.showWindow(self)
        self.setFrameOrigin(NSPoint(x: 1440 - width, y: (900 - height) / 2))
    }
    
    init() {
        super.init(contentRect: NSMakeRect(1440 - width, (900 - height) / 2, width, height),
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
        
        // Volume
        textVolume.backgroundColor = backgroundColor
        textVolume.isBordered = false
        textVolume.textColor = NSColor.white
        textVolume.font = font
        textVolume.alignment = NSTextAlignment.center
        textVolume.isBezeled = false
        textVolume.isEditable = false
        textVolume.setFrameSize(NSSize(width: 50, height: 50))
        textVolume.setFrameOrigin(NSPoint(x: 0, y: 710))
        self.contentView?.addSubview(textVolume)
        
        elementVolume.selected = true
        elementVolume.alphaValue = 1
        elementVolume.setFrameOrigin(NSPoint(x: (width - elementVolume.frame.width) / 2, y: 760))
        elementVolume.down = {return self.elementVolume.switchToElement(self.elementText)}
        self.contentView?.addSubview(elementVolume)
        
        // Text
        textText.backgroundColor = backgroundColor
        textText.isBordered = false
        textText.textColor = NSColor.white
        textText.font = font
        textText.alignment = NSTextAlignment.center
        textText.isBezeled = false
        textText.isEditable = false
        textText.stringValue = "T"
        textText.setFrameSize(NSSize(width: 50, height: 50))
        textText.setFrameOrigin(NSPoint(x: 0, y: 650))
        self.contentView?.addSubview(textText)
        
        elementText.setFrameOrigin(NSPoint(x: (width - elementVolume.frame.width) / 2, y: 700))
        elementText.up = {return self.elementText.switchToElement(self.elementVolume)}
        self.contentView?.addSubview(elementText)
        
    }
    
    func loop(_ timer: Timer) {
        let newTime = NSDate.timeIntervalSinceReferenceDate
        // let fps = 1 / (newTime - lastTime)
        // print(String(format: "%7.3f", fps) + " FPS")
        lastTime = newTime
        
        var defaultOutputDeviceID = AudioDeviceID(0)
        var defaultOutputDeviceIDSize = UInt32(MemoryLayout.size(ofValue: defaultOutputDeviceID))
        
        var getDefaultOutputDevicePropertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
        
        let _ = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &getDefaultOutputDevicePropertyAddress,
            0,
            nil,
            &defaultOutputDeviceIDSize,
            &defaultOutputDeviceID)
        
        var volume = Float32(0.0)
        var volumeSize = UInt32(MemoryLayout.size(ofValue: volume))
        
        var volumePropertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMasterVolume,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMaster)
        
        let _ = AudioObjectGetPropertyData(
            defaultOutputDeviceID,
            &volumePropertyAddress,
            0,
            nil,
            &volumeSize,
            &volume)
        
        textVolume.stringValue = String(Int(round(volume * 16)))
    }
    
}

