//
//  newNode.swift
//  Pro Synth
//
//  Created by Pro Synth on 2017. 08. 31..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

//////////////////////////////////////////////////////////////////////////////////////
//!         Protocols
//////////////////////////////////////////////////////////////////////////////////////
//!         newNodeDelegate
//!===================================================================================
//!         Leírás: Ez a protocol teszi lehetővé, hogy visszajuttassuk az adatokat
//!                 az eredeti newNode létrehozónak
//////////////////////////////////////////////////////////////////////////////////////

protocol newNodeDelegate {

//////////////////////////////////////////////////////////////////////////////////////
//!         Function declarations
//////////////////////////////////////////////////////////////////////////////////////
//!         createNodeFromData()
//!===================================================================================
//!         Leírás: Ez a függvény fogja visszaadni a viewControllernek az adatokat
//!                 ahhoz, hogy létrehozhassa a megfelelő helyen az új pontot
//////////////////////////////////////////////////////////////////////////////////////
    
    func createNodeFromData(name: String, weight:Int, type:NodeType, groupIndex:Int)
 
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
//!                   UI A pont nevének celláját                                {name}
//!                   UI A pont súlyának celláját                         {weightText}
//!                   UI A pont egyesével léptető interfaceét          {weightStepper}
//!                   UI A csoport választóját                                 {group}
//!                   UI Az előzetes súlymeghatározást az optípusból    {opTypePredef}
//!                   UI Automatikus csoportválasztást jelölőnégyzet  {autoGroupAlloc}
//!                   UI Az operáció típusának választója                     {opType}
//////////////////////////////////////////////////////////////////////////////////////

class newNode: NSViewController {

    var delegate:newNodeDelegate?
    var selectionIndex: Int = 0
    var weight : Int = 0

    @IBOutlet weak var name: NSTextField!
    @IBOutlet weak var weightText: NSTextField!
    @IBOutlet weak var weightStepper: NSStepper!
    @IBOutlet weak var opType: NSComboBox!
    @IBOutlet weak var group: NSPopUpButton!
    @IBOutlet weak var opTypePredef: NSButton!
    @IBOutlet weak var autoGroupAlloc: NSButton!

    
//////////////////////////////////////////////////////////////////////////////////////
//!         Functions
//////////////////////////////////////////////////////////////////////////////////////
//!         viewDidLoad()
//!===================================================================================
//!         Leírás: Nézetbeállítások elvégzése, lépték beállítása, alapérték beállítás
//////////////////////////////////////////////////////////////////////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weightStepper.increment = 1
        weightText.stringValue = String(weightStepper.intValue)
    }

    

    
    override func viewDidAppear() {
        
        
        group.removeAllItems()
        group.addItems(withTitles: groupString)
        if (defaultGroupId >= 0) && (defaultGroupId < (groupString.count)){
            group.selectItem(at: defaultGroupId)
        }
        selectionIndex = group.indexOfSelectedItem
        
    }

//////////////////////////////////////////////////////////////////////////////////////
//!         group()
//!===================================================================================
//!         Leírás: Ha változás történik a csoportválasztóban, updateli a kiválasztott
//!                 csoportot
//////////////////////////////////////////////////////////////////////////////////////
    
    @IBAction func group(_ sender: NSPopUpButton) {
        selectionIndex = group.indexOfSelectedItem
    }

//////////////////////////////////////////////////////////////////////////////////////
//!         updateTextField()
//!===================================================================================
//!         Leírás: Ha megnyomják a steppert, updateli a számmezőt
//////////////////////////////////////////////////////////////////////////////////////
    
    @IBAction func updateTextField(_ sender: NSStepper) {
        weightText.stringValue = String(weightStepper.intValue)
    }
    
//////////////////////////////////////////////////////////////////////////////////////
//!         create()
//!===================================================================================
//!         Leírás: updateli a súlyt, meghívja a felegate függvényt, ami visszajuttat-
//!                 ja az adatokat a meghívó viewcontrollernek, és bezárja az ablakot
//////////////////////////////////////////////////////////////////////////////////////
    
    @IBAction func create(_ sender: AnyObject) {
        
        weight = weightStepper.integerValue
        delegate?.createNodeFromData(name: name.stringValue, weight: weight, type: .none, groupIndex: selectionIndex)
        name.stringValue = ""
        weightText.stringValue = "0"
        weightStepper.integerValue = 0
        self.dismissViewController(self)
 
    }
    
//////////////////////////////////////////////////////////////////////////////////////
//!         opTypeChange()
//!===================================================================================
//!         Leírás: Ha op típust választottak, updateli a pont típusát
//!                 TODO
//////////////////////////////////////////////////////////////////////////////////////

    
}

//////////////////////////////////////////////////////////////////////////////////////
//!         Delegate functions implementations
//////////////////////////////////////////////////////////////////////////////////////
//!         controlTextDidChange()
//!===================================================================================
//!         Leírás: Ha a súly textfield-je változott, akkor updateli a stepper értékét
//////////////////////////////////////////////////////////////////////////////////////

extension newNode: NSTextFieldDelegate {
    override func controlTextDidChange(_ obj: Notification) {
        //print(weightText.integerValue)
         weightStepper.integerValue = weightText.integerValue
    }
}
