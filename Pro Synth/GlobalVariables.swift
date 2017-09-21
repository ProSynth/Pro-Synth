//
//  GlobalVariables.swift
//  Pro Synth
//
//  Created by Gergo Markovits on 2017. 09. 21..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

//////////////////////////////////////////////////////////////////////////////////////
//!         Enums
//////////////////////////////////////////////////////////////////////////////////////
//!         NodeType
//!===================================================================================
//!         Leírás: Az egyes pont típusokat definiáló enumeration
//!         TODO
//////////////////////////////////////////////////////////////////////////////////////

enum NodeType {
    case add
    case mul
    case none
}

struct nodeAttributes {
    var name:String
    var weight:Int
    var nodeID:Int
    var groupID:Int
    var numberOfEdge: Int
    
    init (name:String, weight:Int, nodeID:Int, groupID:Int) {
        self.name = name
        self.weight = weight
        self.nodeID = nodeID
        self.groupID = groupID
        self.numberOfEdge = 0
    }
}

var nodeAttributesPl:nodeAttributes = nodeAttributes(name: "", weight: -1, nodeID: -1, groupID: -1)
