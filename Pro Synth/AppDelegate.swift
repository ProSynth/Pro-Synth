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
        print("Klikkeltek rá")
        if addNodeMenuEnabled == true {
            addNodeFromMenu.isEnabled = true
        }
        if addEdgeMenuEnabled == true {
            addEdgeFromMenu.isEnabled = true
        }
    }

    @IBAction func importGraph(_ sender: NSMenuItem) {
        let myFiledialog = NSOpenPanel()
        myFiledialog.prompt = "Import graph"
        //myFiledialog.worksWhenModal = true
        myFiledialog.allowsMultipleSelection = false
        myFiledialog.canChooseDirectories = false
        myFiledialog.canChooseFiles = true
        myFiledialog.allowedFileTypes = ["dot"]
        myFiledialog.beginSheetModal(for: NSApplication.shared().mainWindow!, completionHandler: { num in
            if num == NSModalResponseOK {
                importGraphPath = myFiledialog.url
                NotificationCenter.default.post(name: Notification.Name("importGraphMethod"), object: self)
            } else {
                print("nothing chosen")
            }
        })
    }

    @IBAction func importXMLGraph(_ sender: NSMenuItem) {
        let myFiledialog = NSOpenPanel()
        myFiledialog.prompt = "Import graph"
        //myFiledialog.worksWhenModal = true
        myFiledialog.allowsMultipleSelection = false
        myFiledialog.canChooseDirectories = false
        myFiledialog.canChooseFiles = true
        myFiledialog.allowedFileTypes = ["xml"]
        myFiledialog.beginSheetModal(for: NSApplication.shared().mainWindow!, completionHandler: { num in
            if num == NSModalResponseOK {
                importGraphPath = myFiledialog.url
                NotificationCenter.default.post(name: Notification.Name("importXMLGraphMethod"), object: self)
            } else {
                print("nothing chosen")
            }
        })
    }
    
    @IBAction func exportGraph(_ sender: NSMenuItem) {
        let myFiledialog = NSSavePanel()
        myFiledialog.prompt = "Export graph"
        myFiledialog.allowedFileTypes = ["dot"]
        
        myFiledialog.beginSheetModal(for: NSApplication.shared().mainWindow!, completionHandler: { num in
            if num == NSModalResponseOK {
                exportGraphPath = myFiledialog.url
                NotificationCenter.default.post(name: Notification.Name("exportGraphMethod"), object: self)
            } else {
                print("nothing chosen")
            }
        })
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
    
    public func setNodeEnable(enable: Bool) {
        addNodeFromMenu.isEnabled = enable
    }
    
    public func setEdgeEnable(enable: Bool) {
        addEdgeFromMenu.isEnabled = enable
    }
}

