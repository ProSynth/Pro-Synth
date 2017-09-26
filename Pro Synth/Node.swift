//
//  Node.swift
//  Pro Synth
//
//  Created by Gergo Markovits on 2017. 08. 26..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

//////////////////////////////////////////////////////////////////////////////////////
//!         Class
//////////////////////////////////////////////////////////////////////////////////////
//!         Node (subclass)
//!===================================================================================
//!         Leírás: Egy az objektum írja le a pontot
//!         Superclass: GraphElement
//!         Tartalmazza: Csoportban található élek számát      {numberOfConnectedEdge}
//!                      A pont súyát                                         {weight}
//////////////////////////////////////////////////////////////////////////////////////

class Node: GraphElement {
    var weight: Int                     //Ez lesz a pont súlya
    var numberOfConnectedEdge: Int {
        return children.count
    }      //A ponthoz csatlakozó élek számát adja
    static var  currentNodeID : Int = 0
    var nodeID:Int

//////////////////////////////////////////////////////////////////////////////////////
//!         Function
//////////////////////////////////////////////////////////////////////////////////////
//!         init()
//!===================================================================================
//!         Leírás: Inicializáljuk létrehozásakor a Node-ot a nevével
//!                 Kezdetben nem kapcsolódik hozzá él
//!                 Inicializáláskor megkapja a súlyát
//!///////////////////////////////////////////////////////////////////////////////////

    init(name: String, weight:Int, nodeID: Int = -1) {
        // ID kiosztó szerkezet
        if nodeID == (-1) {
            self.nodeID = Node.currentNodeID
            Node.currentNodeID += 1
        } else {
            self.nodeID = nodeID
            Node.currentNodeID = nodeID
        }
        
        self.weight = weight
        super.init(name: name)
    }
    
    func getWeight() -> Int {
        return self.weight
    }

}
