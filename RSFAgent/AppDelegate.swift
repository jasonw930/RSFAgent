//
//  AppDelegate.swift
//  RSFAgent
//
//  Created by Jason Wang on 2021-04-18.
//  Copyright © 2021 Redstone_Flash. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    // Remember to go to System Preferences > Security & Privacy > Privacy > Accessibility
    
    // UIApplication.shared.delegate as! AppDelegate
    // NSApplication.shared.delegate as! AppDelegate
    
    var hidden = true
    let toolbarWindow = ToolbarWindow()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // NSEvent.addGlobalMonitorForEvents(matching: .keyDown, handler: globalKeyDownHandler)
        // NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: localKeyDownHandler)
        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(1 << CGEventType.keyDown.rawValue),
            callback: cgEventCallback,
            userInfo: nil)
        else {
            print("failed to create event tap")
            exit(1)
        }
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        CFRunLoopRun()
        
        toolbarWindow.show()
        
        Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { timer in
            self.toolbarWindow.loop(timer)
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
    
    func globalKeyDownHandler(event: NSEvent) {
        commonKeyDownHandler(event: event)
    }
    
    func localKeyDownHandler(event: NSEvent) -> NSEvent? {
        commonKeyDownHandler(event: event)
        
        return event
    }
    
    func commonKeyDownHandler(event: NSEvent) {
        if event.modifierFlags.contains(.command) {
            print("command+", terminator: "")
        }
        if event.modifierFlags.contains(.option) {
            print("alt+", terminator: "")
        }
        if event.modifierFlags.contains(.shift) {
            print("shift+", terminator: "")
        }
        print(event.keyCode)
        
        let flags = event.modifierFlags.intersection([.shift, .option, .control, .command])
        
        if flags == [.option, .command] && event.keyCode == 44 {
            if !hidden {
                toolbarWindow.alphaValue = 1
                toolbarWindow.animator().alphaValue = 0
            } else {
                toolbarWindow.alphaValue = 0
                toolbarWindow.animator().alphaValue = 1
            }
            hidden = !hidden
            return
        }
        
        if flags == [.option, .command] && event.keyCode == 123 {
            if hidden {
                toolbarWindow.alphaValue = 0
                toolbarWindow.animator().alphaValue = 1
                hidden = !hidden
            }
            NSApplication.shared.activate(ignoringOtherApps: true)
            return
        }
    }

}

func cgEventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    if type == .keyDown {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        let flags = event.flags.intersection([.maskShift, .maskAlternate, .maskControl, .maskCommand])
        
        if flags.contains(.maskShift) {
            print("shift+", terminator: "")
        }
        if flags.contains(.maskAlternate) {
            print("alt+", terminator: "")
        }
        if flags.contains(.maskControl) {
            print("control+", terminator: "")
        }
        if flags.contains(.maskCommand) {
            print("command+", terminator: "")
        }
        print(keyCode)
        
        if flags == [.maskAlternate, .maskCommand] && keyCode == 44 {
            if !appDelegate.hidden {
                appDelegate.toolbarWindow.alphaValue = 1
                appDelegate.toolbarWindow.animator().alphaValue = 0
            } else {
                appDelegate.toolbarWindow.alphaValue = 0
                appDelegate.toolbarWindow.animator().alphaValue = 1
            }
            appDelegate.hidden = !appDelegate.hidden
            return nil
        }
    }
    return Unmanaged.passRetained(event)
}
