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
    @IBOutlet weak var weightText: NSTextField!
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
        
        operationType.removeAllItems()
        for i in 0..<nodeOpTypeArray.count {
            operationType.addItem(withObjectValue: nodeOpTypeArray[i].name)
        }
    }
    
    @IBAction func updateTextField(_ sender: NSStepper) {
        weightText.stringValue = String(weightStepper.intValue)
    }
    
    func update() {
        name.stringValue = tmpNodeAttribute.name
        nodeID.stringValue = String(tmpNodeAttribute.nodeID)
        weightText.integerValue = tmpNodeAttribute.weight
        numberOfEdge.integerValue = tmpNodeAttribute.numberOfConnectedEdge
        weightStepper.integerValue = weightText.integerValue

    }
    
}

extension nodeGlobalAttributeViewController: NSTextFieldDelegate {
    override func controlTextDidChange(_ obj: Notification) {
        weightStepper.integerValue = weightText.integerValue
    }
}
