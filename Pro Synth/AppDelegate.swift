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
    

    @IBAction func addNodeFromMenu(_ sender: NSMenuItem) {
        

        
    }

    var welcomeWindowController : NSWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        let welcomeScreen = NSStoryboard(name: "welcomeScreen", bundle: nil)
        welcomeWindowController = welcomeScreen.instantiateController(withIdentifier: "welcomeScreenWindowController") as? NSWindowController
        welcomeWindowController?.showWindow(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

