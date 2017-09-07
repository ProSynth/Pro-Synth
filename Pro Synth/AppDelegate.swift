//
//  AppDelegate.swift
//  Pro Synth
//
//  Created by Gergo Markovits on 2017. 08. 17..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa



@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var addNodeFromMenu: NSMenuItem!
    @IBOutlet weak var addEdgeFromMenu: NSMenuItem!

    @IBAction func graphMenuClicked(_ sender: Any) {
        if addNodeMenuEnabled == true {
            addNodeFromMenu.isEnabled = true
        }
        if addEdgeMenuEnabled == true {
            addEdgeFromMenu.isEnabled = true
        }
    }

    @IBAction func addNodeFromMenu(_ sender: NSMenuItem) {
        NotificationCenter.default.post(name: Notification.Name("hotKeyNode"), object: self)

        
    }

    @IBAction func addGroupFromMenu(_ sender: NSMenuItem) {
        NotificationCenter.default.post(name: Notification.Name("hotKeyGroup"), object: self)
    }
    
    @IBAction func addEdgeFromMenu(_ sender: NSMenuItem) {
        NotificationCenter.default.post(name: Notification.Name("hotKeyEdge"), object: self)
    }
    var welcomeWindowController : NSWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        let welcomeScreen = NSStoryboard(name: "welcomeScreen", bundle: nil)
        welcomeWindowController = welcomeScreen.instantiateController(withIdentifier: "welcomeScreenWindowController") as? NSWindowController
        welcomeWindowController?.showWindow(self)
        addNodeFromMenu.isEnabled = false
        addEdgeFromMenu.isEnabled = false
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

