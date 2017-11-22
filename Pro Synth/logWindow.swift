//
//  logWindow.swift
//  Pro Synth
//
//  Created by Markovits Gergő on 2017. 11. 22..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

class logWindow: NSViewController {

    @IBOutlet weak var logText: NSScrollView!
    @IBOutlet var logTextView: NSTextView!
    static var localLog: String!
    
    @IBAction func deleteLog(_ sender: Any) {
       logTextView.isEditable = true
        logTextView.selectAll(sender)
        logTextView.delete(sender)
        logTextView.isEditable = false
        print("Törlés végrhajtva")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        NotificationCenter.default.addObserver(self, selector: #selector(self.addLocalLog), name: Notification.Name("addLog"), object: nil)
        logTextView.textStorage?.append(NSAttributedString(string: "Pro Synth up and running\nCreated by \nGyörgy Rácz & Gergő Markovits \n© IIT BME"))
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.title = "Pro Synth - Log Window"
    }
    
    func addLocalLog() {
        let tmpLog = logWindow.localLog
        self.logTextView.textStorage?.append(NSAttributedString(string: tmpLog!))
    }
    
    static public func addLog(log: String) {
        localLog = log
        
        NotificationCenter.default.post(name: Notification.Name("addLog"), object: self)
        
    }
    
}
