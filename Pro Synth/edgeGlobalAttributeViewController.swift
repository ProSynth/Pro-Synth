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
    @IBOutlet weak var sourceNodeID: NSTextField!
    @IBOutlet weak var destinationNodeID: NSTextField!
    @IBOutlet weak var edgeTypeSelector: NSPopUpButton!
    @IBOutlet weak var edgeTypePredefined: NSButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        NotificationCenter.default.addObserver(self, selector: #selector(self.update), name: Notification.Name("edgeAttribute"), object: nil)
        update()
        edgeTypeSelector.removeAllItems()
        for i in 0..<edgeDataTypeArray.count {
            edgeTypeSelector.addItem(withTitle: edgeDataTypeArray[i].name)
        }
        weightText.isEnabled = false
        weightStepper.isEnabled = false
    }
    @IBAction func updateTextField(_ sender: Any) {
        weightText.stringValue = String(weightStepper.intValue)
    }
    
    func update() {
        name.stringValue = tmpEdgeAttribute.name
        edgeID.stringValue = String(tmpEdgeAttribute.edgeID)
        weightText.integerValue = tmpEdgeAttribute.weight
        weightStepper.integerValue = weightText.integerValue
        sourceNodeID.integerValue = tmpEdgeAttribute.parentsNode.nodeID
        destinationNodeID.integerValue = tmpEdgeAttribute.parentdNode.nodeID
        
        edgeTypeSelector.selectItem(withTitle: (tmpEdgeAttribute.type.name))
    }
    @IBAction func edgeTypeChanged(_ sender: NSPopUpButton) {
        tmpEdgeAttribute.type = edgeDataTypeArray[sender.indexOfSelectedItem]
        if edgeTypePredefined.state == NSOnState {
            tmpEdgeAttribute.weight = edgeDataTypeArray[sender.indexOfSelectedItem].defaultWeight
            weightText.integerValue = edgeDataTypeArray[sender.indexOfSelectedItem].defaultWeight
        }
    }
}

extension edgeGlobalAttributeViewController: NSTextFieldDelegate {
    override func controlTextDidChange(_ obj: Notification) {
        weightStepper.integerValue = weightText.integerValue
        tmpEdgeAttribute.name = name.stringValue
        if edgeTypePredefined.state != NSOnState {
            tmpEdgeAttribute.weight = weightText.integerValue
        }
    }
}
