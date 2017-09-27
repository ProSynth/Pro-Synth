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

struct groupAttributes {
    var name:String
    var groupID:Int
    var numberOfNode: Int
    var maxTime: Int
    
    init (name:String, weight:Int, nodeID:Int, groupID:Int) {
        self.maxTime = -1
        self.name = name
        self.groupID = groupID
        self.numberOfNode = 0
    }
}

struct edgeAttributes {
    var name : String
    var edgeID : Int
    var weight : Int
    init (name:String, weight:Int, edgeID:Int) {
 
        self.name = name
        self.weight = weight
        self.edgeID = edgeID
    }
}

class edgeDataType {
    
    var name : String
    var defaultWeight : Int
    
    init(name:String, defaultWeight:Int) {
        self.name = name
        self.defaultWeight = defaultWeight
    }
    
}

var edgeDataTypeArray = [edgeDataType]()

var edgeAttributesP1:edgeAttributes = edgeAttributes(name: "", weight: -1, edgeID: -1)
var nodeAttributesPl:nodeAttributes = nodeAttributes(name: "", weight: -1, nodeID: -1, groupID: -1)
var groupAttributesP1:groupAttributes = groupAttributes(name: "", weight: -1, nodeID: -1, groupID: -1)

