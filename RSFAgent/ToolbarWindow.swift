//
//  ToolbarWindow.swift
//  RSFAgent
//
//  Created by Jason Wang on 2021-04-18.
//  Copyright © 2021 Redstone_Flash. All rights reserved.
//

import Cocoa
import AudioToolbox

class ToolbarWindow: Window {

    var lastTime = NSDate.timeIntervalSinceReferenceDate
    
    let width: CGFloat = 50
    let height: CGFloat = 780
    let font = NSFont.init(name: "Helvetica Neue", size: 30)
    
    let textVolume = NSTextField()
    let elementVolume = Element()
    
    let textText = NSTextField()
    let elementText = Element()
    
    let textTrackpad = NSTextField()
    let elementTrackpad = Element()
        
    func show() {
        let controller = NSWindowController(window: self)
        controller.showWindow(self)
        self.setFrameOrigin(NSPoint(x: 1440 - width, y: (900 - height) / 2))
    }
    
    init() {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        super.init(contentRect: NSMakeRect(1440 - width, (900 - height) / 2, width, height),
                   styleMask: [.titled, .fullSizeContentView], backing: .buffered, defer: false);
        
        self.alphaValue = 0
        open = true
        
        setupWindow()
        
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
        
        elementText.setFrameOrigin(NSPoint(x: (width - elementText.frame.width) / 2, y: 700))
        elementText.left = {
            Element.enterWindow(appDelegate.textWindow)
            return self.elementText.switchToElement(appDelegate.textWindow.elementText)
        }
        elementText.up = {return self.elementText.switchToElement(self.elementVolume)}
        elementText.down = {return self.elementText.switchToElement(self.elementTrackpad)}
        self.contentView?.addSubview(elementText)
        
        // Trackpad
        textTrackpad.backgroundColor = backgroundColor
        textTrackpad.isBordered = false
        textTrackpad.textColor = NSColor.white
        textTrackpad.font = font
        textTrackpad.alignment = NSTextAlignment.center
        textTrackpad.isBezeled = false
        textTrackpad.isEditable = false
        textTrackpad.stringValue = "TP"
        textTrackpad.setFrameSize(NSSize(width: 50, height: 50))
        textTrackpad.setFrameOrigin(NSPoint(x: 0, y: 590))
        self.contentView?.addSubview(textTrackpad)
        
        elementTrackpad.setFrameOrigin(NSPoint(x: (width - elementText.frame.width) / 2, y: 640))
        elementTrackpad.left = {
            Element.enterWindow(appDelegate.trackpadWindow)
            return self.elementTrackpad.switchToElement(appDelegate.trackpadWindow.elementMode)
        }
        elementTrackpad.up = {return self.elementTrackpad.switchToElement(self.elementText)}
        self.contentView?.addSubview(elementTrackpad)
        
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

