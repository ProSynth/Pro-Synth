//
//  edgeGlobalAttributeViewController.swift
//  Pro Synth
//
//  Created by Gergo Markovits on 2017. 09. 23..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

class edgeGlobalAttributeViewController: NSViewController {

    @IBOutlet weak var name: NSTextField!
    @IBOutlet weak var edgeID: NSTextField!
    @IBOutlet weak var weightText: NSTextField!
    @IBOutlet weak var weightStepper: NSStepper!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        NotificationCenter.default.addObserver(self, selector: #selector(self.update), name: Notification.Name("edgeAttribute"), object: nil)
        update()
    }
    @IBAction func updateTextField(_ sender: Any) {
        weightText.stringValue = String(weightStepper.intValue)
    }
    
    func update() {
        name.stringValue = edgeAttributesP1.name
        edgeID.stringValue = String(edgeAttributesP1.edgeID)
        weightText.integerValue = edgeAttributesP1.weight
        weightStepper.integerValue = weightText.integerValue
    }
}

extension edgeGlobalAttributeViewController: NSTextFieldDelegate {
    override func controlTextDidChange(_ obj: Notification) {
        weightStepper.integerValue = weightText.integerValue
    }
}
