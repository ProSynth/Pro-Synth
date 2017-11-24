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
    @IBOutlet weak var operationTypePopUp: NSPopUpButton!
    @IBOutlet weak var operationPredefined: NSButton!
    @IBOutlet weak var group: NSPopUpButton!
    @IBOutlet weak var numberOfEdge: NSTextField!
    @IBOutlet weak var IOType: NSTextField!
    
    var indexInItsGroup: Int!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do view setup here.
        //graphViewController?.globalAttributeDelegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.update), name: Notification.Name("nodeAttribute"), object: nil)
        update()
        
        operationTypePopUp.removeAllItems()
        for i in 0..<nodeOpTypeArray.count {
            operationTypePopUp.addItem(withTitle: nodeOpTypeArray[i].name)
        }

        weightText.isEnabled = false
        weightStepper.isEnabled = false

    }
    @IBAction func Predefined(_ sender: NSButton) {
        if sender.state == NSOnState {
            weightText.isEnabled = false
            weightStepper.isEnabled = false
        } else {
            weightText.isEnabled = true
            weightStepper.isEnabled = true
        }
    }
    
    @IBAction func updateTextField(_ sender: NSStepper) {
        weightText.stringValue = String(weightStepper.intValue)
        tmpNodeAttribute.weight = weightStepper.integerValue
    }
    
    func update() {
        name.stringValue = tmpNodeAttribute.name
        nodeID.stringValue = String(tmpNodeAttribute.nodeID)
        weightText.integerValue = tmpNodeAttribute.weight
        numberOfEdge.integerValue = tmpNodeAttribute.numberOfConnectedEdge
        weightStepper.integerValue = weightText.integerValue
        if tmpNodeAttribute.type == .Input {
            IOType.stringValue = "Input"
        } else if tmpNodeAttribute.type == .Output {
            IOType.stringValue = "Output"
        }
        operationTypePopUp.selectItem(withTitle: (tmpNodeAttribute.opType?.name)!)
        group.removeAllItems()
        for i in 0..<tmpGroupArray.count {
            group.addItem(withTitle: (tmpGroupArray[i] as GraphElement).name)
        }
        let index = tmpGroupArray.index(where: { $0.groupID == (tmpNodeAttribute.parent as! Group).groupID})
        group.selectItem(at: index!)
    }
    @IBAction func groupDidChanged(_ sender: NSPopUpButton) {
        tmpGroupArray[sender.indexOfSelectedItem].children.append(tmpNodeAttribute)
        indexInItsGroup = tmpNodeAttribute.parent?.children.index(where: { ($0 as! Node).nodeID == tmpNodeAttribute.nodeID})
        tmpNodeAttribute.parent?.children.remove(at: indexInItsGroup)
    }
    
    @IBAction func operationTypeDidChanged(_ sender: NSPopUpButton) {
        tmpNodeAttribute.opType = nodeOpTypeArray[sender.indexOfSelectedItem]
        if operationPredefined.state == NSOnState {
            tmpNodeAttribute.weight = nodeOpTypeArray[sender.indexOfSelectedItem].defaultWeight
            weightText.integerValue = nodeOpTypeArray[sender.indexOfSelectedItem].defaultWeight
        }
    }
}



extension nodeGlobalAttributeViewController: NSTextFieldDelegate {
    override func controlTextDidChange(_ obj: Notification) {
        weightStepper.integerValue = weightText.integerValue
        tmpNodeAttribute.weight = weightStepper.integerValue
        tmpNodeAttribute.name = name.stringValue
    }
}
