//
//  AppDelegate.swift
//  KernelCaches Rebuilder
//
//  Created by Nattapong Pullkhow on 11/30/2557 BE.
//  Copyright (c) 2557 Nattapong Pullkhow. All rights reserved.
//

import Cocoa
import Foundation

class AppDelegate: NSObject, NSApplicationDelegate {
                            
    
    @IBOutlet var window: NSWindow
    @IBOutlet var VersionTEXT : NSTextField
    @IBAction func ShowAboutWindow(sender : AnyObject) {
        VersionTEXT.stringValue = "Version \(Version.Main()) build \(Version.Build())"
        self.window.orderFront(window)
    }
    @IBAction func setQuit(sender : AnyObject) {
        if (self.window.visible) {
            self.window.orderOut(window)
        } else if (self.ConfirmWindow.visible) {
            self.ConfirmWindow.orderOut(ConfirmWindow)
            if (!self.MainWindow.visible) {
                self.MainWindow.orderFront(window)
            }
        } else if (self.MainWindow.visible || self.ResultWindow.visible) {
            NSApplication.sharedApplication().terminate(self)
        }
    }



    @IBOutlet var MainWindow : NSPanel
    
    @IBAction func RemoveRebuildIconClick(sender : AnyObject) {
        setConfirm("remove", ConfirmTitle_: "Remove KernelCaches", ConfirmText_: "Are you sure to remove KernelCaches? System may rebuild Kernelcaches Automaticaly.",ConfirmIconText_: "Remove")
    }
    
    @IBAction func TouchRebuildIconClick(sender : AnyObject) {
        setConfirm("touch", ConfirmTitle_: "Touch /S/L/E", ConfirmText_: "Are you sure to Rebuild KernelCaches By Touch /System/Library/Extensions/?",ConfirmIconText_: "Touch")
    }
    @IBAction func ForceRebuildIconClick(sender : AnyObject) {
        setConfirm("force", ConfirmTitle_: "Force Rebuild KernelCaches", ConfirmText_: "Are you sure to \"Force Rebuild KernelCache\" this Solution is too risk?",ConfirmIconText_: "Force Rebuild")
    }
    @IBOutlet var ConfirmWindow : NSPanel
    @IBOutlet var ConfirmIcon : NSButton
    
    @IBAction func ConfirmIconClick(sender : AnyObject) {
        setRebuild()
    }
    @IBOutlet var ConfirmIconText : NSTextField
    @IBOutlet var ConfirmTitle : NSTextField
    @IBOutlet var ConfirmText : NSTextField
    @IBAction func ConfirmCancelClick(sender : AnyObject) {
        ConfirmWindow.orderOut(ConfirmWindow)
        MainWindow.orderFront(MainWindow)
    }
    
    @IBOutlet var ResultWindow : NSPanel
    @IBOutlet var ResultTitle: NSTextField
    @IBOutlet var ResultText : NSTextField
    @IBAction func ResultCloseClick(sender : AnyObject) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    
    
    var RebuildSolution = String()
    var sessionAction = String()

    func setConfirm(RebuildAction_:String,ConfirmTitle_:String,ConfirmText_:String,ConfirmIconText_:String) {
        if(self.MainWindow.visible) { self.MainWindow.orderOut(MainWindow) }
        if(RebuildAction_ == "touch" || RebuildAction_ == "remove" || RebuildAction_ == "force") {
            RebuildSolution = "\(RebuildAction_)"
            if(!self.ConfirmWindow.visible) {
                ConfirmWindow.orderFront(ConfirmWindow)
                let rebuildIcon = NSImage(named: RebuildAction_)
                ConfirmIcon.image = rebuildIcon
                ConfirmText.stringValue = "\(ConfirmText_)"
                ConfirmTitle.stringValue = "\(ConfirmTitle_)"
                ConfirmIconText.stringValue = "\(ConfirmIconText_)"
            }
        }
    }
    func setRebuild() {
        if(RebuildSolution == "force") {
            forceRebuild()
        } else if (RebuildSolution == "touch") {
            touchRebuild()
        } else if (RebuildSolution == "remove") {
            removeRebuild()
        }
        if (self.ConfirmWindow.visible) {
            self.ConfirmWindow.orderOut(ConfirmWindow)
        }
    }
    func forceRebuild() {
        println(RebuildSolution)
        var OSSarg = [ "-e","do shell script \"touch /System/Library/Extensions/ && kextcache -prelinked-kernel /System/Library/Caches/com.apple.kext.caches/Startup/kernelcache -K /System/Library/Kernels/kernel /System/Library/Extensions/ && echo 'Done'\" with administrator privileges"]
        var Task = NSTask()
        Task.launchPath = "/usr/bin/osascript"
        Task.arguments = OSSarg
        let _pipe = NSPipe()
        Task.standardOutput = _pipe
        Task.launch()
        let data = _pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = removeWhiteSpace(NSString(data: data,encoding: NSUTF8StringEncoding))
        if(output.rangeOfString("Done")) {
            setSuccess()
        } else {
            setError()
        }
    }
    func touchRebuild() {
        var OSSarg = [ "-e","do shell script \"touch /System/Library/Extensions/ && echo 'Done'\" with administrator privileges"]
        var Task = NSTask()
        Task.launchPath = "/usr/bin/osascript"
        Task.arguments = OSSarg
        let _pipe = NSPipe()
        Task.standardOutput = _pipe
        Task.launch()
        let data = _pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = removeWhiteSpace(NSString(data: data,encoding: NSUTF8StringEncoding))
        if(output.rangeOfString("Done")) { setSuccess() } else { setError() }
    }
    func removeRebuild() {
        println(RebuildSolution)
        var OSSarg = [ "-e","do shell script \"rm -rf /System/Library/Caches/com.apple.kext.caches/Startup/kernelcache && echo 'Done'\" with administrator privileges"]
        var Task = NSTask()
        Task.launchPath = "/usr/bin/osascript"
        Task.arguments = OSSarg
        let _pipe = NSPipe()
        Task.standardOutput = _pipe
        Task.launch()
        let data = _pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = removeWhiteSpace(NSString(data: data,encoding: NSUTF8StringEncoding))
        if(output.rangeOfString("Done")) { setSuccess() } else { setError() }
    }
    func setSuccess() {
        ResultText.stringValue = "Rebuild KernelCaches Success You Need to Restart System."
        ResultTitle.stringValue = "Operation  Success!"
        if(!ResultWindow.visible) { ResultWindow.orderFront(ResultWindow) }
    }
    func setError() {
        ResultText.stringValue = "Rebuild KernelCaches no Success.Please,Try Again Later."
        ResultTitle.stringValue = "Operation Error!"
        if(!ResultWindow.visible) { ResultWindow.orderFront(ResultWindow) }
    }
    func removeWhiteSpace(string:String)->String {
        let text = string.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).filter({!$0.isEmpty})
        return " ".join(text)
    }
    class Version {
        class func Main()->String {
            let version: AnyObject? = NSBundle.mainBundle().infoDictionary["CFBundleShortVersionString"]
            return version as String
        }
        class func Build()->String {
            let build: AnyObject? = NSBundle.mainBundle().infoDictionary["CFBundleVersion"]
            return build as String
        }
    }
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }


}

