//
//  groupGlobalAttributeViewController.swift
//  Pro Synth
//
//  Created by Gergo Markovits on 2017. 09. 23..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

class groupGlobalAttributeViewController: NSViewController {

    @IBOutlet weak var name: NSTextField!
    @IBOutlet weak var groupID: NSTextField!
    @IBOutlet weak var maxTime: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        NotificationCenter.default.addObserver(self, selector: #selector(self.update), name: Notification.Name("groupAttribute"), object: nil)
        update()
    }
    
    func update() {
        name.stringValue = groupAttributesP1.name
        groupID.stringValue = String(groupAttributesP1.groupID)
        maxTime.integerValue = groupAttributesP1.maxTime
    }
    
}
