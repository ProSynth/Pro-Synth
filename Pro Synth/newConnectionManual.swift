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
    
    func createConnectionFromData(name: String, weight:Int, type:EdgeType, node1Index:IndexPath, node2Index: IndexPath)
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
    @IBOutlet weak var busDefined: NSButton!
    @IBOutlet weak var busType: NSPopUpButton!
    @IBOutlet weak var customName: NSButton!
    @IBOutlet weak var name: NSTextField!
    @IBOutlet weak var nameLabel: NSTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
    }
    
    override func viewDidAppear() {
        busType.isEnabled = false
        name.isEnabled = false
        node1Selector.removeAllItems()
        node2Selector.removeAllItems()
        node1Selector.addItems(withTitles: nodeString)
        node2Selector.addItems(withTitles: nodeString)
        
        name.stringValue = "\(nodeString[node1Selector.indexOfSelectedItem])-\(nodeString[node2Selector.indexOfSelectedItem])"
    }
    
    @IBAction func busTypeDefined(_ sender: NSButton) {
        switch busDefined.state {
        case NSOnState:
            busType.isEnabled = true
            break
        case NSOffState:
            busType.isEnabled = false
            break
        default:
            return
        }
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
            break
        default:
            return
        }
    }
    
    @IBAction func create(_ sender: NSButton) {
        
        delegate?.createConnectionFromData(name: name.stringValue, weight: weightStepper.integerValue, type: .none, node1Index: nodePath[node1Selector.indexOfSelectedItem], node2Index: nodePath[node2Selector.indexOfSelectedItem])
        self.dismissViewController(self)
    }
}
