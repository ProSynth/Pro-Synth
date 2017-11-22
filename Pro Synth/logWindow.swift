//
//  logWindow.swift
//  Pro Synth
//
//  Created by Markovits Gergő on 2017. 11. 22..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

class logWindow: NSViewController {

    @IBOutlet weak var detailSelector: NSSegmentedControl!
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
        logTextView.textStorage?.append(NSAttributedString(string: "Pro Synth up and running\nCreated by \nGyörgy Rácz & Gergő Markovits \n© IIT BME\n"))
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.title = "Pro Synth - Log Window"
    }
    
    func Print2(log: String, detailed: Detail = .High) {
        //let text = log + "\n"

        self.logTextView.textStorage?.append(NSAttributedString(string: log))
        self.logTextView.textStorage?.append(NSAttributedString(string: "\n"))
        if detailed.rawValue >= detailSelector.selectedSegment {
            
            
        }
        
    }
    func Print(log: String, detailed: Detail = .High) {
        DispatchQueue.global().async(execute: {
            if let view = self.logTextView {
                view.appendText(line: log)
            }
            })

    }
}

extension NSTextView {
    func appendText(line: String) {
        
     
            DispatchQueue.main.async {
                //let attrDict = [NSFontAttributeName: NSFont.systemFont(ofSize: 18.0)]
                let astring = NSAttributedString(string: "\(line)\n")
                self.textStorage?.append(astring)
                let loc = self.string?.lengthOfBytes(using: String.Encoding.utf8)
                
                let range = NSRange(location: loc!, length: 0)
                self.scrollRangeToVisible(range)
            }
      
    }
}
