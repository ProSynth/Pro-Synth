//
//  WindowController.swift
//  Pro Synth
//
//  Created by Gergo Markovits on 2017. 10. 02..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    @IBOutlet weak var sidebars: NSSegmentedControl!
    @IBOutlet weak var windowName: NSTextFieldCell!
    
    
    var projName: String = "Untitled Project"
    var logWindowController: NSWindowController?
    var logViewController: logWindow?
    
    var scheduleWindowController: NSWindowController?
    var scheduleViewController: SchedulingResultViewController?
    
    override func windowDidLoad() {
        super.windowDidLoad()
        if logWindowController == nil {
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            logWindowController = storyboard.instantiateController(withIdentifier: "LogWindow") as? NSWindowController
            logViewController = logWindowController?.contentViewController as? logWindow
            Log = logViewController
            logWindowController?.close()
        }
        
        if scheduleWindowController == nil {
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            scheduleWindowController = storyboard.instantiateController(withIdentifier: "ScheduleResult") as? NSWindowController
            scheduleViewController = scheduleWindowController?.contentViewController as? SchedulingResultViewController
            SchedRes = scheduleViewController
            scheduleWindowController?.close()
        }
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        window?.titleVisibility = .hidden

        windowName.stringValue = projName
    }

    @IBAction func hideShowSidebar(_ sender: NSSegmentedControl) {

        if sidebars.isSelected(forSegment: 0) {
            NotificationCenter.default.post(name: Notification.Name("showGraphSidebar"), object: self)
        } else {
            NotificationCenter.default.post(name: Notification.Name("hideGraphSidebar"), object: self)
        }
        
        if sidebars.isSelected(forSegment: 1) {
            NotificationCenter.default.post(name: Notification.Name("showAttrSidebar"), object: self)
        } else {
            NotificationCenter.default.post(name: Notification.Name("hideAttrSidebar"), object: self)
        }
    }
    
    @IBAction func start(_ sender: NSToolbarItem) {
        NotificationCenter.default.post(name: Notification.Name("startSynth"), object: self)
    }
    
    @IBAction func pause(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name("pauseSynth"), object: self)
    }
    
    
    @IBAction func openLogWindow(_ sender: Any) {
        if logWindowController != nil {
            logWindowController?.showWindow(sender)
        }
    }
    
    @IBAction func openScheduleResult(_ sender: Any) {
        if scheduleWindowController != nil {
            scheduleWindowController?.showWindow(sender)
        }
    }
    
}
