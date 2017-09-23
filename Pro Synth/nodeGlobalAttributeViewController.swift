//
//  nodeGlobalAttributeViewController.swift
//  Pro Synth
//
//  Created by Gergo Markovits on 2017. 09. 17..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//



import Cocoa



class nodeGlobalAttributeViewController: NSViewController {

    @IBOutlet weak var name: NSTextField!
    @IBOutlet weak var nodeID: NSTextField!
    @IBOutlet weak var weight: NSTokenField!
    @IBOutlet weak var weightStepper: NSStepper!
    @IBOutlet weak var operationType: NSComboBox!
    @IBOutlet weak var operationPredefined: NSButton!
    @IBOutlet weak var group: NSPopUpButton!
    @IBOutlet weak var numberOfEdge: NSTextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do view setup here.
        //graphViewController?.globalAttributeDelegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.update), name: Notification.Name("nodeAttribute"), object: nil)
        update()
    }
    
    func update() {
        name.stringValue = nodeAttributesPl.name
        nodeID.stringValue = String(nodeAttributesPl.nodeID)
        weight.integerValue = nodeAttributesPl.weight
        numberOfEdge.integerValue = nodeAttributesPl.numberOfEdge
    }
    
}

