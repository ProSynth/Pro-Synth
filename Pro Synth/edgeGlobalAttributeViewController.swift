//
//  edgeGlobalAttributeViewController.swift
//  Pro Synth
//
//  Created by Gergo Markovits on 2017. 09. 23..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

class edgeGlobalAttributeViewController: NSViewController {


    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        NotificationCenter.default.addObserver(self, selector: #selector(self.update), name: Notification.Name("edgeAttribute"), object: nil)
        update()
    }
    
    func update() {
        //name.stringValue = edgeAttributesP1.name
        //edgeID.stringValue = String(edgeAttributesP1.edgeID)
        //weight.integerValue = edgeAttributesP1.weight
    }
}
