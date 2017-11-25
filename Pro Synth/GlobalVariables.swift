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
enum IO {
    case Normal
    case Input
    case Output
}

enum LoopType {
    case None
    case ACI
    case Normal
}

enum SynthType {
    case WNCut
    case RSCU
    case SFDS
}

enum Detail: Int {
    case Low            = 0
    case Normal         = 1
    case High           = 2
}

enum RSCUDecType {
    case FastWNCut
    case WNCut
    case FastNCut
    case NCut
}

struct nodeAttributes {
    var name:String
    var weight:Int
    var nodeID:Int
    var groupID:Int
    var numberOfEdge: Int
    var opType: nodeOpType
    
    init (name:String, weight:Int, nodeID:Int, groupID:Int, opType:nodeOpType) {
        self.name = name
        self.weight = weight
        self.nodeID = nodeID
        self.groupID = groupID
        self.numberOfEdge = 0
        self.opType = opType
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

class nodeOpType {
    
    var name: String
    var defaultWeight: Int
    
    init(name:String, defaultWeight:Int) {
        self.name = name
        self.defaultWeight = defaultWeight
    }
}

var synthProcess: SynthType? = nil

var edgeDataTypeArray = [edgeDataType]()
var nodeOpTypeArray = [nodeOpType]()

var edgeAttributesP1:edgeAttributes = edgeAttributes(name: "", weight: -1, edgeID: -1)
var nodeAttributesPl:nodeAttributes = nodeAttributes(name: "", weight: -1, nodeID: -1, groupID: -1, opType: nodeOpType(name: "", defaultWeight: -1))
var groupAttributesP1:groupAttributes = groupAttributes(name: "", weight: -1, nodeID: -1, groupID: -1)

var groupAttribute:Group = Group(name: "Attribútum", parent: nil, maxGroupTime: 0, groupID: -2)
//var nodeAttribute: Node = Node(name: " ", parent: nil, weight: -1, nodeOpType: nodeOpTypeArray[0], nodeID: -2)
var tmpNodeAttribute: Node!
var tmpGroupAttribute: Group!
var tmpEdgeAttribute: Edge!
var tmpGroupArray = [Group]()

var Log: logWindow?
var SynthViewController: synthesisViewController?





/* WNCut globális változói */

