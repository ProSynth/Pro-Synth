//
//  newConnectionManual.swift
//  Pro Synth
//
//  Created by Pro Synth on 2017. 09. 05..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

//////////////////////////////////////////////////////////////////////////////////////
//!         Protocols
//////////////////////////////////////////////////////////////////////////////////////
//!         newConnectionDelegate
//!===================================================================================
//!         Leírás: Ez a protocol teszi lehetővé, hogy visszajuttassuk az adatokat
//!                 az eredeti newConnectionManual létrehozónak
//////////////////////////////////////////////////////////////////////////////////////

protocol newConnectionDelegate {
    
//////////////////////////////////////////////////////////////////////////////////////
//!         Function declarations
//////////////////////////////////////////////////////////////////////////////////////
//!         createConnectionFromData()
//!===================================================================================
//!         Leírás: Ez a függvény fogja visszaadni a viewControllernek az adatokat
//!                 ahhoz, hogy létrehozhassa a megfelelő helyen az új élet
//////////////////////////////////////////////////////////////////////////////////////
    
    func createConnectionFromData(name: String, weight:Int, type: edgeDataType, node1Index:IndexPath, node2Index: IndexPath)
}

//////////////////////////////////////////////////////////////////////////////////////
//!         Class
//////////////////////////////////////////////////////////////////////////////////////
//!         newNode
//!===================================================================================
//!         Leírás: A pont hozzáadás űrlapnak a viewControllere
//!         Superclass: NSViewController
//!         Tartalmazza: A protokoll delegációját                           {delegate}
//!                      A kiválasztott csoport indexét               {selectionIndex}
//!                      A pont súlyát                                        {weight}
//!                   UI Az él egyik pontjának kiválasztója            {node1Selector}
//!                   UI Az él másik pontjának kiválasztója            {node2Selector}
//!                   UI Az él egyesével léptető interfaceét           {weightStepper}
//!                   UI Az él súlyának beviteli mezőjét                  {weightText}
//!                   UI Meghatározunk-e busztípust jelölőnégyzet         {busDefined}
//!                   UI Busztípus kiválasztója                              {busType}
//!                   UI Akarunk-e neki saját nevet adni jelölőnégyzet    {customName}
//!                   UI Az él neve beviteli mező                               {name}
//!                   TODO
//////////////////////////////////////////////////////////////////////////////////////

class newConnectionManual: NSViewController {
    
    var delegate:newConnectionDelegate?
   
    var selectionIndex1 = 0
    var selectionIndex2 = 0
    
    @IBOutlet weak var node1Selector: NSPopUpButton!
    @IBOutlet weak var node2Selector: NSPopUpButton!
    @IBOutlet weak var weightText: NSTextField!
    @IBOutlet weak var weightStepper: NSStepper!
    @IBOutlet weak var isNewDataType: NSButton!
    @IBOutlet weak var newDataTypeText: NSTextField!
    @IBOutlet weak var existingDataTypes: NSPopUpButton!
    @IBOutlet weak var customName: NSButton!
    @IBOutlet weak var name: NSTextField!
    @IBOutlet weak var nameLabel: NSTextField!

    
    @IBOutlet weak var cancel: NSButton!
    @IBOutlet weak var create: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        weightStepper.increment = 1
        weightText.stringValue = String(weightStepper.intValue)
    }
    
    @IBAction func newDataChange(_ sender: NSButton) {
        if sender.state == NSOnState {
            existingDataTypes.isEnabled = false
            newDataTypeText.isEnabled = true
        } else {
            existingDataTypes.isEnabled = true
            newDataTypeText.isEnabled = false
        }
    }
    
    override func viewDidAppear() {
        isNewDataType.isEnabled = false
        name.isEnabled = false
        node1Selector.removeAllItems()
        node2Selector.removeAllItems()
        node1Selector.addItems(withTitles: nodeString)
        node2Selector.addItems(withTitles: nodeString)
        
        existingDataTypes.isEnabled = true
        newDataTypeText.isEnabled = false
        
        create.keyEquivalent = "\u{0d}"
        cancel.keyEquivalent = "\u{1b}"
        
        existingDataTypes.removeAllItems()
        for i in 0..<edgeDataTypeArray.count {
            existingDataTypes.addItem(withTitle: edgeDataTypeArray[i].name)
        }
        
        name.stringValue = "\(nodeString[node1Selector.indexOfSelectedItem])-\(nodeString[node2Selector.indexOfSelectedItem]) connection"
    }
    
    @IBAction func nodeIsChanged(_ sender: NSPopUpButton) {
        name.stringValue = "\(nodeString[node1Selector.indexOfSelectedItem])-\(nodeString[node2Selector.indexOfSelectedItem]) connection"
    }
    

    
    @IBAction func customName(_ sender: NSButton) {
        switch customName.state {
        case NSOnState:
            name.stringValue = ""
            name.isEnabled = true
            nameLabel.isEnabled = true
            break
        case NSOffState:
            name.isEnabled = false
            nameLabel.isEnabled = false
            name.stringValue = "\(nodeString[node1Selector.indexOfSelectedItem])-\(nodeString[node2Selector.indexOfSelectedItem]) connection"
            break
        default:
            return
        }
    }
    @IBAction func updateTextField(_ sender: NSStepper) {
        weightText.stringValue = String(weightStepper.intValue)
    }
    
    @IBAction func create(_ sender: NSButton) {
        var tmpEdgeDataType: edgeDataType!
        if isNewDataType.state == NSOnState {
            tmpEdgeDataType = edgeDataType(name: newDataTypeText.stringValue, defaultWeight: weightText.integerValue)
        } else {
            tmpEdgeDataType = edgeDataTypeArray[existingDataTypes.indexOfSelectedItem]
        }
        
        delegate?.createConnectionFromData(name: name.stringValue, weight: weightStepper.integerValue, type: tmpEdgeDataType, node1Index: nodePath[node1Selector.indexOfSelectedItem], node2Index: nodePath[node2Selector.indexOfSelectedItem])
        weightText.stringValue = "0"
        weightStepper.integerValue = 0
    
        self.dismissViewController(self)
    }
}

extension newConnectionManual: NSTextFieldDelegate {
    override func controlTextDidChange(_ obj: Notification) {
        weightStepper.integerValue = weightText.integerValue
    }
}
