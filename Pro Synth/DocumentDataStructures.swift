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
    //var name: [UInt8]
     //var opTypeName: [UInt8]
    var nodeID: Int
    var weight: Int
    var numberOfConnectedEdge: Int
    var opTypeWeight: Int
    var spectrum: Double
    var startTime: Int
    var type: IO
    var parentID: Int
    
    init(nodeID: Int, weight: Int, numberOfConnectedEdge: Int, opTypeWeight: Int, spectrum: Double, startTime: Int, type: IO, parentID: Int) {
        self.nodeID = nodeID
        self.weight = weight
        self.numberOfConnectedEdge = numberOfConnectedEdge
        //self.opTypeName = Array(repeatElement(32, count: 50))
        self.opTypeWeight = opTypeWeight
        self.spectrum = spectrum
        self.startTime = startTime
        self.type = type
        //self.name = Array(repeatElement(32, count: 50))
        self.parentID = parentID
    }
}

struct EdgeData {
    //var name: [UInt8]
    var edgeID: Int
    var weight: Int
    //var typeName: [UInt8]
    var typeWeight: Int
    var parentSNodeID: Int
    var parentDNodeID: Int
    
    init(edgeID: Int, weight: Int, typeWeight: Int, parentSNodeID: Int, parentDNodeID: Int) {
        self.edgeID = edgeID
        self.weight = weight
        self.typeWeight = typeWeight
        self.parentSNodeID = parentSNodeID
        self.parentDNodeID = parentDNodeID
        //self.name = Array(repeatElement(32, count: 50))
        //self.typeName = Array(repeatElement(32, count: 50))
    }
}

struct GroupData {
    //var name: [UInt8]
    var groupID: Int
    var parentID: Int
    var numberOfNodes: Int
    var maxTime: Int
    var loop: LoopType
    var loopCount: Int
    
    init(groupID: Int, numberOfNodes: Int, maxTime: Int, loop: LoopType, loopCount: Int, parentID: Int = 0xFFFFFFFF) {
        self.groupID = groupID
        self.numberOfNodes = numberOfNodes
        self.maxTime = maxTime
        self.loop = loop
        self.loopCount = loopCount
        self.parentID = parentID
        //self.name = Array(repeatElement(32, count: 50))
    }
}

class DocumentDataStructures: NSObject {
    
    var GroupStack = [UInt8]()
    var NodeStack = [UInt8]()
    var EdgeStack = [UInt8]()
    
    var GroupCount: UInt16 = 0
    var NodeCount: UInt16 = 0
    var EdgeCount: UInt16  = 0
    
    func addGroupToStack(group: Group) {
        // Az opcionális változóknak értéket adunk
        if group.loopCount == nil {
            group.loopCount = 0
        }
        // Megnézzük, hogy root-e
        var parentID: Int
        if group.parent == nil {
            parentID = 0xFFFFFFFF
        } else {
            parentID = (group.parent as! Group).groupID
        }
        // Létrehozzuk a név nélküle csoport adatstruktúrát
        var tmpGroupData = GroupData(groupID: group.groupID, numberOfNodes: group.numberOfNode, maxTime: group.maxTime, loop: group.loop, loopCount: group.loopCount!, parentID: parentID)
        // Létrehozzuk az 50 karakteres nevet, és feltöltjük a Groupstacket vele
        var ctr = 0
        for char in group.name.utf8{
            GroupStack += [char]
            ctr += 1
        }
        while ctr < 50 {
            GroupStack.append(32)
            ctr += 1
        }
        // Feltöltjük a többi struktúrát is
        withUnsafeBytes(of: &tmpGroupData) { bytes in
            for byte in bytes {
                GroupStack.append(byte)
            }
        }
    }
    
    func addNodeToStack(node: Node) {
        // Az opcionális változóknak értéket adunk
        if node.spectrum == nil {
            node.spectrum = 0
        }
        if node.startTime == nil {
            node.startTime = 0
        }
        // Megnézzük, hoyg root-e
        var parentID: Int
        if node.parent == nil {
            parentID = 0xFFFFFFFF
        } else {
            parentID = (node.parent as! Group).groupID
        }
        // Létrehozzuk a nevek nélküli csoport adatstruktúrát
        var tmpNodeData = NodeData(nodeID: node.nodeID, weight: node.weight, numberOfConnectedEdge: node.numberOfConnectedEdge, opTypeWeight: (node.opType?.defaultWeight)!, spectrum: node.spectrum!, startTime: node.startTime!, type: node.type, parentID: parentID)
        // Létrehozzuk a 2x50 karakteres neveket, és feltöltjük vele a NodeStacket
        var ctr = 0
        for char in node.name.utf8{
            NodeStack += [char]
            ctr += 1
        }
        while ctr < 50 {
            NodeStack.append(32)
            ctr += 1
        }
        ctr = 0
        for char in (node.opType?.name.utf8)!{
            NodeStack += [char]
            ctr += 1
        }
        while ctr < 50 {
            NodeStack.append(32)
            ctr += 1
        }
        // Feltöltjük a többi struktúrát is
        withUnsafeBytes(of: &tmpNodeData) { bytes in
            for byte in bytes {
                NodeStack.append(byte)
            }
        }
    }
    
    func addEdgeToStack(edge: Edge) {
        var tmpEdgeData = EdgeData(edgeID: edge.edgeID, weight: edge.weight, typeWeight: edge.type.defaultWeight, parentSNodeID: edge.parentsNode.nodeID, parentDNodeID: edge.parentdNode.nodeID)
        // Létrehozzuk a 2x50 karakteres neveket, és feltöltjük vele a NodeStacket
        var ctr = 0
        for char in edge.name.utf8{
            EdgeStack += [char]
            ctr += 1
        }
        while ctr < 50 {
            EdgeStack.append(32)
            ctr += 1
        }
        ctr = 0
        for char in (edge.type.name.utf8){
            EdgeStack += [char]
            ctr += 1
        }
        while ctr < 50 {
            EdgeStack.append(32)
            ctr += 1
        }
        // Feltöltjük a többi struktúrát is
        withUnsafeBytes(of: &tmpEdgeData) { bytes in
            for byte in bytes {
                EdgeStack.append(byte)
            }
        }
    }
    
    func findGraphElement(groups: [GraphElement], isRoot: Bool) {
        for i in 0..<groups.count {
            if groups[i] is Group {
                // Adjuk hozzá a groupot a GroupStackhez
                addGroupToStack(group: groups[i] as! Group)
                GroupCount += 1
                findGraphElement(groups: groups[i].children, isRoot: false)
            } else if groups[i] is Node {
                // Adjuk hozzá a Nodeot a NodeStackhez
                addNodeToStack(node: groups[i] as! Node)
                NodeCount += 1
                if !(groups[i].children.isEmpty) {
                    findGraphElement(groups: groups[i].children, isRoot: false)
                }
            } else if groups[i] is Edge {
                // Adjuk hozzá az Edget az EdgeStackhez
                addEdgeToStack(edge: groups[i] as! Edge)
                EdgeCount += 1
            }
        }
    }
    
    func toFile(allGroups: [[GraphElement]]) {
        
        
        
        
        for i in 0..<header.sw_name.count {
            stackBytes.append(header.sw_name[i])
        }
        withUnsafeBytes(of: &header) { bytes in
            var ctr = 0
            for byte in bytes {
                if ctr > 7 {
                    stackBytes.append(byte)
                    print(byte)
                }
                
                ctr += 1
            }
        }
        // Az összes csoport számának meghatározása
        var allGroupsCount = UInt16(allGroups.count)
        withUnsafeBytes(of: &allGroupsCount) { bytes in
            for byte in bytes {
                stackBytes.append(byte)
            }
        }
        
        for i in 0..<allGroups.count {
            
            findGraphElement(groups: allGroups[i], isRoot: true)
            
            // Csoportok száma
            var tmpGroupCount = GroupCount
            print("(A csoportok száma:\(tmpGroupCount))")
            withUnsafeBytes(of: &tmpGroupCount) { bytes in
                for byte in bytes {
                    stackBytes.append(byte)
                }
            }
            stackBytes.append(contentsOf: GroupStack)
            GroupStack.removeAll()
            GroupCount = 0
            
            // Nodeok száma
            var tmpNodeCount = NodeCount
            withUnsafeBytes(of: &tmpNodeCount) { bytes in
                for byte in bytes {
                    stackBytes.append(byte)
                }
            }
            stackBytes.append(contentsOf: NodeStack)
            NodeStack.removeAll()
            NodeCount = 0
            
            // Csoportok száma
            var tmpEdgeCount = EdgeCount
            withUnsafeBytes(of: &tmpEdgeCount) { bytes in
                for byte in bytes {
                    stackBytes.append(byte)
                }
            }
            stackBytes.append(contentsOf: EdgeStack)
            EdgeStack.removeAll()
            EdgeCount = 0
        }
        //print(stackBytes)
        isReady = true
    }
}
