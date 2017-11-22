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
    var logWindowController: NSWindowController?
    var logViewController: logWindow?
    
    override func windowDidLoad() {
        super.windowDidLoad()
        if logWindowController == nil {
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            logWindowController = storyboard.instantiateController(withIdentifier: "LogWindow") as? NSWindowController
            logViewController = logWindowController?.contentViewController as? logWindow
            Log = logViewController
            logWindowController?.close()
        }
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        window?.titleVisibility = .hidden
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
    @IBAction func openLogWindow(_ sender: Any) {
        if logWindowController != nil {
            logWindowController?.showWindow(sender)
        }
    }
    
}
