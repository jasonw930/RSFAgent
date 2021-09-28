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
    var windows: [Window]!
    var toolbarWindow: ToolbarWindow!
    var textWindow: TextWindow!
    var trackpadWindow: TrackpadWindow!
    var trackpadBoundsWindow: TrackpadBoundsWindow!
    var oLogBehaviourWindow: OLogBehaviourWindow!
    var oLogTriggerWindow: OLogTriggerWindow!
    var oLogSaveWindow: OLogSaveWindow!
    var curElement: Element!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // NSEvent.addGlobalMonitorForEvents(matching: .keyDown, handler: globalKeyDownHandler)
        // NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: localKeyDownHandler)
        
        toolbarWindow = ToolbarWindow()
        textWindow = TextWindow()
        trackpadWindow = TrackpadWindow()
        trackpadBoundsWindow = TrackpadBoundsWindow()
        oLogBehaviourWindow = OLogBehaviourWindow()
        oLogTriggerWindow = OLogTriggerWindow()
        oLogSaveWindow = OLogSaveWindow()
        windows = [toolbarWindow, textWindow, trackpadWindow, trackpadBoundsWindow, oLogBehaviourWindow, oLogTriggerWindow, oLogSaveWindow]
        curElement = toolbarWindow.elementVolume
        print("Windows Created")
        
        toolbarWindow.makeKey()
        toolbarWindow.show()
        textWindow.show()
        trackpadWindow.show()
        trackpadBoundsWindow.show()
        oLogBehaviourWindow.show()
        oLogTriggerWindow.show()
        oLogSaveWindow.show()
        print("Windows Showed")
        
        Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { timer in
            self.toolbarWindow.loop(timer)
        }
        
        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(1 << CGEventType.keyDown.rawValue | 1 << 29), // 29 is gesture event, CGEventType doesn't define, stinky!!!
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
        print("Tap Created")
        
        print("Finished Launching")
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
    
}

func cgEventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    if type == .keyDown {
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        let flags = event.flags.intersection([.maskShift, .maskAlternate, .maskControl, .maskCommand])
        var char = UniChar()
        var length = 0
        event.keyboardGetUnicodeString(maxStringLength: 1, actualStringLength: &length, unicodeString: &char)
        
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
        
        // cmd+alt+/
        if flags == [.maskAlternate, .maskCommand] && keyCode == 44 {
            if !appDelegate.hidden {
                for w in appDelegate.windows {
                    if w.open {
                        w.alphaValue = 1
                        w.animator().alphaValue = 0
                    }
                }
            } else {
                for w in appDelegate.windows {
                    if w.open {
                        w.alphaValue = 0
                        w.animator().alphaValue = 1
                    }
                }
            }
            appDelegate.hidden = !appDelegate.hidden
            return nil
        }
        
        // cmd+left cmd+right cmd+up cmd+down
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
        
        if !appDelegate.hidden && appDelegate.curElement == appDelegate.textWindow.elementText {
            let page = appDelegate.textWindow.pages[appDelegate.textWindow.curPage]
            
            if flags == [] && 123 <= keyCode && keyCode <= 126 {
                switch keyCode {
                case 123:
                    page.moveLeft(nil)
                case 124:
                    page.moveRight(nil)
                case 125:
                    page.moveDown(nil)
                case 126:
                    page.moveUp(nil)
                default:
                    break
                }
                appDelegate.textWindow.updateTextField()
                return nil
            }
            
            if (flags == [] || flags == [.maskShift]) && (97 <= char && char <= 122 || 65 <= char && char <= 90 || [13, 32].contains(char)) {
                page.insertText("\(Character(UnicodeScalar(char)!))")
                appDelegate.textWindow.updateTextField()
                return nil
            }
            
            if flags == [] && char == 8 {
                page.deleteBackward(nil)
                appDelegate.textWindow.updateTextField()
                return nil
            }
        }
    } else if type.rawValue == 29 {
        // print("Gesture!!")
        let nsEvent = NSEvent(cgEvent: event)
        let touch = nsEvent!.allTouches().first
        if touch != nil {
            // print("\(touch!.normalizedPosition)")
            if appDelegate.trackpadWindow.absolute {
                let bounds = appDelegate.trackpadBoundsWindow.bounds.map{CGFloat($0)}
                var x = (touch!.normalizedPosition.x - bounds[0]) / (bounds[1] - bounds[0]) * 1440
                x = max(0, min(1440, x))
                var y = (1 - (touch!.normalizedPosition.y - bounds[2]) / (bounds[3] - bounds[2])) * 900
                y = max(0, min(900, y))
                CGDisplayMoveCursorToPoint(CGMainDisplayID(), NSPoint(x: x, y: y))
            }
        }
    }
    return Unmanaged.passRetained(event)
}
