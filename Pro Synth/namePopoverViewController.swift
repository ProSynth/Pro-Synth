//
//  namePopoverViewController.swift
//  Pro Synth
//
//  Created by Markovits Gergő on 2017. 11. 25..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

protocol SynthNameDidChanged {
    func update()
}

class namePopoverViewController: NSViewController {
    
    var _name: String = ""
    var _replace: Bool {
        get {
            if replaceSynth.state == NSOnState {
                return true
            } else {
                return false
            }
        }
    }
    
    @IBOutlet weak var name: NSTextField!
    @IBOutlet weak var replaceSynth: NSButton!
    @IBOutlet weak var save: NSButton!
    @IBOutlet weak var cancel: NSButton!
    
    var delegate: SynthNameDidChanged?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        name.stringValue = _name
        save.keyEquivalent = "\u{0d}"
        cancel.keyEquivalent = "\u{1b}"
    }
    
    @IBAction func save(_ sender: NSButton) {
        NotificationCenter.default.post(name: Notification.Name("saveName"), object: self)
        dismissViewController(self)
    }
}
