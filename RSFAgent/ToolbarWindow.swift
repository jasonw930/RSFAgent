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
    
    let textFPS = NSTextField()
    
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
        
        // FPS Textbox
        textFPS.backgroundColor = self.backgroundColor
        textFPS.isBordered = false
        textFPS.textColor = NSColor.white
        textFPS.font = font
        textFPS.alignment = NSTextAlignment.center
        textFPS.setFrameOrigin(NSPoint(x: 0, y: 720))
        textFPS.setFrameSize(NSSize(width: 50, height: 50))
        textFPS.isBezeled = false
        textFPS.isEditable = false
        self.contentView?.addSubview(textFPS)
        
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
        
        textFPS.stringValue = String(Int(round(volume * 16)))
    }
    
}

