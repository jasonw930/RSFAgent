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
    var toolbarWindow: ToolbarWindow!
    var textWindow: TextWindow!
    var curElement: Element!
    
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
        
        toolbarWindow = ToolbarWindow()
        textWindow = TextWindow()
        curElement = toolbarWindow.elementVolume
        
        toolbarWindow.makeKey()
        toolbarWindow.show()
        textWindow.show()
        
        Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { timer in
            self.toolbarWindow.loop(timer)
        }
        
        print("Finished Launching")
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
        
        if flags == [.maskCommand] && 123 <= keyCode && keyCode <= 126 {
            if !appDelegate.hidden {
                switch keyCode {
                case 123:
                    appDelegate.curElement = appDelegate.curElement.left()
                case 124:
                    appDelegate.curElement = appDelegate.curElement.right()
                case 125:
                    appDelegate.curElement = appDelegate.curElement.down()
                case 126:
                    appDelegate.curElement = appDelegate.curElement.up()
                default:
                    break
                }
                return nil
            }
            return Unmanaged.passRetained(event)
        }
    }
    return Unmanaged.passRetained(event)
}
