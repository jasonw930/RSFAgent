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
    
    let textOLog = NSTextField()
    let elementOLog = Element()
        
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
        initToolbarItem(textVolume, pos: 0)
        
        elementVolume.selected = true
        elementVolume.alphaValue = 1
        elementVolume.setFrameOrigin(NSPoint(x: (width - elementVolume.frame.width) / 2, y: 760))
        elementVolume.down = {return self.elementVolume.switchToElement(self.elementText)}
        self.contentView?.addSubview(elementVolume)
        
        // Text
        initToolbarItem(textText, pos: 1)
        textText.stringValue = "T"
        
        elementText.setFrameOrigin(NSPoint(x: (width - elementText.frame.width) / 2, y: 700))
        elementText.left = {
            Element.enterWindow(appDelegate.textWindow)
            return self.elementText.switchToElement(appDelegate.textWindow.elementText)
        }
        elementText.up = {return self.elementText.switchToElement(self.elementVolume)}
        elementText.down = {return self.elementText.switchToElement(self.elementTrackpad)}
        self.contentView?.addSubview(elementText)
        
        // Trackpad
        initToolbarItem(textTrackpad, pos: 2)
        textTrackpad.stringValue = "TP"
        
        elementTrackpad.setFrameOrigin(NSPoint(x: (width - elementText.frame.width) / 2, y: 640))
        elementTrackpad.left = {
            Element.enterWindow(appDelegate.trackpadWindow)
            return self.elementTrackpad.switchToElement(appDelegate.trackpadWindow.elementMode)
        }
        elementTrackpad.up = {return self.elementTrackpad.switchToElement(self.elementText)}
        elementTrackpad.down = {return self.elementTrackpad.switchToElement(self.elementOLog)}
        self.contentView?.addSubview(elementTrackpad)
        
        // OLog
        initToolbarItem(textOLog, pos: 3)
        textOLog.stringValue = "OL"
        
        elementOLog.setFrameOrigin(NSPoint(x: (width - elementText.frame.width) / 2, y: 580))
        elementOLog.left = {
            Element.enterWindow(appDelegate.oLogBehaviourWindow)
            return self.elementOLog.switchToElement(appDelegate.oLogBehaviourWindow.elementBehaviour)
        }
        elementOLog.up = {return self.elementOLog.switchToElement(self.elementTrackpad)}
        self.contentView?.addSubview(elementOLog)
    }
    
    func initToolbarItem(_ tf: NSTextField, pos: Int) {
        tf.backgroundColor = backgroundColor
        tf.isBordered = false
        tf.textColor = NSColor.white
        tf.font = font
        tf.alignment = NSTextAlignment.center
        tf.isBezeled = false
        tf.isEditable = false
        tf.setFrameSize(NSSize(width: 50, height: 50))
        tf.setFrameOrigin(NSPoint(x: 0, y: 710 - 60 * pos))
        self.contentView?.addSubview(tf)
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

