//
//  DocumentDataStructures.swift
//  Pro Synth
//
//  Created by Markovits Gergő on 2017. 11. 26..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

struct Header {
    var sw_name: [UInt8] = [80, 114, 111, 32, 83, 121, 110, 116, 104]
    var sw_major: UInt8 = 0
    var sw_minor: UInt8 = 9
    var file_version: UInt8 = 1
}

struct NodeData {
    var name: [UInt8]
    var nodeID: Int
    var weight: Int
    var numberOfConnectedEdge: Int
    var opTypeName: [UInt8]
    var opTypeWeight: Int
    var spectrum: Double
    var startTime: Int
    var type: IO
    var parentID: Int
    
    init(nodeID: Int, weight: Int, numberOfConnectedEdge: Int, opTypeWeight: Int, spectrum: Double, startTime: Int, type: IO, parentID: Int) {
        self.nodeID = nodeID
        self.weight = weight
        self.numberOfConnectedEdge = numberOfConnectedEdge
        self.opTypeName = Array(repeatElement(32, count: 50))
        self.opTypeWeight = opTypeWeight
        self.spectrum = spectrum
        self.startTime = startTime
        self.type = type
        self.name = Array(repeatElement(32, count: 50))
        self.parentID = parentID
    }
}

struct EdgeData {
    var name: [UInt8]
    var edgeID: Int
    var weight: Int
    var typeName: [UInt8]
    var typeWeight: Int
    var parentSNodeID: Int
    var parentDNodeID: Int
    
    init(edgeID: Int, weight: Int, typeWeight: Int, parentSNodeID: Int, parentDNodeID: Int) {
        self.edgeID = edgeID
        self.weight = weight
        self.typeWeight = typeWeight
        self.parentSNodeID = parentSNodeID
        self.parentDNodeID = parentDNodeID
        self.name = Array(repeatElement(32, count: 50))
        self.typeName = Array(repeatElement(32, count: 50))
    }
}

struct GroupData {
    var name: [UInt8]
    var groupID: Int
    var numberOfNodes: Int
    var maxTime: Int
    var loop: LoopType
    var loopCount: Int
    
    init(groupID: Int, numberOfNodes: Int, maxTime: Int, loop: LoopType, loopCount: Int) {
        self.groupID = groupID
        self.numberOfNodes = numberOfNodes
        self.maxTime = maxTime
        self.loop = loop
        self.loopCount = loopCount
        self.name = Array(repeatElement(32, count: 50))
    }
}

class DocumentDataStructures: NSObject {

}
