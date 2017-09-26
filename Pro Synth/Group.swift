
//
//  Group.swift
//  Pro Synth
//
//  Created by Gergo Markovits on 2017. 08. 26..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

//////////////////////////////////////////////////////////////////////////////////////
//!         Class
//////////////////////////////////////////////////////////////////////////////////////
//!         Group (subclass) : GraphElement (superclass)
//!===================================================================================
//!         Leírás: Egy az objektum írja le a csoportot
//!         Tartalmazza: csoportban található pontok számát             {numberOfNode}
//////////////////////////////////////////////////////////////////////////////////////

class Group: GraphElement {
    var numberOfNode: Int                       //Megadja, hogy a csoportban összesen hány Node van
    static var  currentGroupID : Int = 0
    var groupID : Int                           //CsoportID, minden csoportnak különböző
    var maxTime:Int
    

//////////////////////////////////////////////////////////////////////////////////////
//!         Function
//////////////////////////////////////////////////////////////////////////////////////
//!         init()
//!===================================================================================
//!         Leírás: Inicializáljuk létrehozásakor a Groupot a nevével
//!                 TODO: numberOfNode rendes implementációja
//////////////////////////////////////////////////////////////////////////////////////
    
    init(name: String, maxGroupTime: Int, groupID: Int = -1) {
        
        if groupID == (-1) {
            self.groupID = Group.currentGroupID
            Group.currentGroupID += 1
        } else {
            self.groupID = groupID
            Group.currentGroupID = groupID
        }
        print(self.groupID)
        self.maxTime = maxGroupTime

        self.numberOfNode = 0
        super.init(name: name)
    }
    
    func getGroupID() -> Int {
        return self.groupID
    }
    
}
