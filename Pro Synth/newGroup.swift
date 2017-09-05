//
//  newGroup.swift
//  Pro Synth
//
//  Created by Gergo Markovits on 2017. 09. 02..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

//////////////////////////////////////////////////////////////////////////////////////
//!         Protocols
//////////////////////////////////////////////////////////////////////////////////////
//!         newGroupDelegate
//!===================================================================================
//!         Leírás: Ez a protocol teszi lehetővé, hogy visszajuttassuk az adatokat
//!                 az eredeti newGroup létrehozónak
//////////////////////////////////////////////////////////////////////////////////////

protocol newGroupDelegate {
    
//////////////////////////////////////////////////////////////////////////////////////
//!         Function declarations
//////////////////////////////////////////////////////////////////////////////////////
//!         createGroupFromData()
//!===================================================================================
//!         Leírás: Ez a függvény fogja visszaadni a viewControllernek az adatokat
//!                 ahhoz, hogy létrehozhassa a megfelelő helyen az új csoportot
//////////////////////////////////////////////////////////////////////////////////////
    
    func createGroupFromData(name: String)
}

//////////////////////////////////////////////////////////////////////////////////////
//!         Class
//////////////////////////////////////////////////////////////////////////////////////
//!         newGroup
//!===================================================================================
//!         Leírás: A csoport hozzáadás űrlapnak a viewControllere
//!         Superclass: NSViewController
//!         Tartalmazza: A protokoll delegációját                           {delegate}
//!                   UI A csoport nevének celláját                             {name}
//////////////////////////////////////////////////////////////////////////////////////

class newGroup: NSViewController {
    
    var delegate:newGroupDelegate?

    @IBOutlet weak var name: NSTextField!

//////////////////////////////////////////////////////////////////////////////////////
//!         Functions
//////////////////////////////////////////////////////////////////////////////////////
//!         create()
//!===================================================================================
//!         Leírás: Meghívja a delegate függvényt, aminek az egyetlen paramétere a
//!                 neve lesz, és kitörli a szöveget, és bezárja az ablakot
//////////////////////////////////////////////////////////////////////////////////////

    @IBAction func create(_ sender: Any) {
        delegate?.createGroupFromData(name: name.stringValue)
        name.stringValue = ""
        self.dismissViewController(self)
    }

//////////////////////////////////////////////////////////////////////////////////////
//!         viewDidLoad()
//!===================================================================================
//!         Leírás: Nézetbeállítások elvégzése, lépték beállítása, alapérték beállítás
//////////////////////////////////////////////////////////////////////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
