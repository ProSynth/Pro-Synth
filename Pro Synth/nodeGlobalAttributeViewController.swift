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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do view setup here.
        //graphViewController?.globalAttributeDelegate = self
    }
    
}

extension nodeGlobalAttributeViewController : globalAttributeDelegate {
    func loadAttributes(name: String, weight: Int, nodeID: Int, opType: NodeType, group: GraphElement) {
        print("A fv meghívódik")
        self.name.stringValue = name
        self.weight.intValue = Int32(weight)
        self.nodeID.intValue = Int32(nodeID)
    }
}
