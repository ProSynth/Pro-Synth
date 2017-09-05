//
//  Edge.swift
//  Pro Synth
//
//  Created by Gergo Markovits on 2017. 08. 26..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

enum EdgeType {
    case i2c
    case uart
    case none
}

//////////////////////////////////////////////////////////////////////////////////////
//!         Class
//////////////////////////////////////////////////////////////////////////////////////
//!         Edge (subclass) : GraphElement (superclass)
//!===================================================================================
//!         Leírás: Egy az objektum írja le a pontot
//!         Tartalmazza: Az él súyát                                          {weight}
//!                      Az él típusát                                          {type}
//////////////////////////////////////////////////////////////////////////////////////

class Edge: GraphElement {
    var weight: Int                     //Ez lesz az él súlya
    var type: EdgeType                  //Kapcoslat típusa
    
//////////////////////////////////////////////////////////////////////////////////////
//!         Function
//////////////////////////////////////////////////////////////////////////////////////
//!         init()
//!===================================================================================
//!         Leírás: Inicializáljuk létrehozásakor a Edge-et a nevével
//!                 Inicializáláskor megkapja a súlyát
//!///////////////////////////////////////////////////////////////////////////////////
    
    init(name: String, weight:Int) {
        self.weight = weight
        self.type = .none
        super.init(name: name)
    }
    
    


}
