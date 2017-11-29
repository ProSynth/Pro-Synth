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

struct ScheduleResultData {
    var allGroupsIndex: UInt16
    var latency: Int
    var restartTime: Int
    var processorUsage = [Int]()
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
    var type: Int
    var parentID: Int
    
    init(nodeID: Int, weight: Int, numberOfConnectedEdge: Int, opTypeWeight: Int, spectrum: Double, startTime: Int, type: Int, parentID: Int) {
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
    var loop: Int
    var loopCount: Int
    
    init(groupID: Int, numberOfNodes: Int, maxTime: Int, loop: Int, loopCount: Int, parentID: Int = 0xFFFFFFFF) {
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
    
    var groupID_Group = [Int : Group]()
    var groupID_ParentID = [Int : Int]()
    var groups = [Group]()
    
    var nodeID_Node = [Int : Node]()
    var nodeID_ParentID = [Int : Int]()
    var nodes = [Node]()
    
    var edgeID_Edge = [Int : Edge]()
    var edgeID_sNodeID = [Int : Int]()
    var edgeID_dNodeID = [Int : Int]()
    var edges = [Edge]()
    
    var GroupStack = [UInt8]()
    var NodeStack = [UInt8]()
    var EdgeStack = [UInt8]()
    var SchedResStack = [UInt8]()
    
    let defaultParent = Node(name: "", parent: nil, weight: 0, nodeOpType: nil, nodeID: 0xFFFFFFFE)
    
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
        //Megnézzük a Loop typusát
        var _loop: Int
        switch group.loop {
        case .None:
            _loop = 0
        case .ACI:
            _loop = 1
        case .Normal:
            _loop = 2
        default:
            break
        }
        
        // Létrehozzuk a név nélküle csoport adatstruktúrát
        var tmpGroupData = GroupData(groupID: group.groupID, numberOfNodes: group.numberOfNode, maxTime: group.maxTime, loop: _loop, loopCount: group.loopCount!, parentID: parentID)
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
        
        var IOtype: Int
        switch node.type {
        case .Normal:
            IOtype = 0
        case .Input:
            IOtype = 1
        case .Output:
            IOtype = 2
        default:
            break
        }
        
        // Létrehozzuk a nevek nélküli csoport adatstruktúrát
        var tmpNodeData = NodeData(nodeID: node.nodeID, weight: node.weight, numberOfConnectedEdge: node.numberOfConnectedEdge, opTypeWeight: (node.opType?.defaultWeight)!, spectrum: node.spectrum!, startTime: node.startTime!, type: IOtype, parentID: parentID)
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
    
    func toFile(allGroups: [[GraphElement]], allGroupsNames: [String]) {
        
        
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
            
            // Gráfok nevei
            var ctr = 0
            var name = allGroupsNames[i]
            /*
            print("(A gráf neve:\(name))")
            withUnsafeBytes(of: &name) { bytes in
                for byte in bytes {
                    stackBytes.append(byte)
                    ctr += 1
                }
            }
            while ctr < 50 {
                stackBytes.append(32)
                ctr += 1
            }
            */
            
            for char in name.utf8{
                stackBytes += [char]
                ctr += 1
            }
            while ctr < 50 {
                stackBytes.append(32)
                ctr += 1
            }
            
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
            
            // Élek száma
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
        
        // Scheduling Resultok feltöltése
        var SchedulesCount = UInt16(persScheduleResults.count)
        withUnsafeBytes(of: &SchedulesCount) { bytes in
            for byte in bytes {
                stackBytes.append(byte)
            }
        }
        for i in 0..<persScheduleResults.count {
            let tmpLatency = persScheduleResults[i].latency
            let tmpRestartTime = persScheduleResults[i].restartTime
            let index = persScheduleResults[i].allGroupsIndex
            var tmpScheduleData = ScheduleResultData(allGroupsIndex: index, latency: tmpLatency, restartTime: tmpRestartTime, processorUsage: [])
            for j in 0..<persScheduleResults[i].processorUsage.count {
                tmpScheduleData.processorUsage.append(persScheduleResults[i].processorUsage[j])
            }
            
            withUnsafeBytes(of: &tmpScheduleData) { bytes in
                for byte in bytes {
                    SchedResStack.append(byte)
                }
            }
        }
        
        stackBytes.append(contentsOf: SchedResStack)
        isReady = true
        print(stackBytes)
    }
    
    //MARK: - Olvasás
    
    func parseGroup(data: inout [UInt8]) {
        var name: String!
        if let string = String(data: Data(bytes: Array(data[0..<50])), encoding: .utf8) {
            print(string)
            name = string
        } else {
            print("not a valid UTF-8 sequence")
            name = "Undefined"
        }
        data = Array(data.dropFirst(50))
        
        let groupID = Int(littleEndian: Data(bytes: Array(data[0..<8])).withUnsafeBytes { $0.pointee })
        data = Array(data.dropFirst(8))
        
        let parentID = Int(littleEndian: Data(bytes: Array(data[0..<8])).withUnsafeBytes { $0.pointee })
        data = Array(data.dropFirst(8))
        
        let numberOfNodes = Int(littleEndian: Data(bytes: Array(data[0..<8])).withUnsafeBytes { $0.pointee })
        data = Array(data.dropFirst(8))
        
        let maxTime = Int(littleEndian: Data(bytes: Array(data[0..<8])).withUnsafeBytes { $0.pointee })
        data = Array(data.dropFirst(8))
        
        let loop = Int(littleEndian: Data(bytes: Array(data[0..<8])).withUnsafeBytes { $0.pointee })
        data = Array(data.dropFirst(8))
        
        let loopCount = Int(littleEndian: Data(bytes: Array(data[0..<8])).withUnsafeBytes { $0.pointee })
        data = Array(data.dropFirst(8))
        
        // Group létrehozása
        var _loop: LoopType!
        switch loop {
        case 0:
            _loop = .None
        case 1:
            _loop = .ACI
        case 2:
            _loop = .Normal
        default:
            break
        }
        let tmpGroup = Group(name: name, parent: nil, maxGroupTime: maxTime, groupID: groupID, loop: _loop)
        if loopCount == 0 {
            tmpGroup.loopCount = nil
        } else {
            tmpGroup.loopCount = loopCount
        }
        
        // Group hozzáadása a groupID : Group szótárhoz
        groupID_Group[groupID] = tmpGroup
        groupID_ParentID[groupID] = parentID
        
        // Group hozzáadása az udeiglenes tömbhöz?
        groups.append(tmpGroup)
    }
    
    func parseNode(data: inout [UInt8]) {
        // A Node nevének leszedése
        var name: String!
        if let string = String(data: Data(bytes: Array(data[0..<50])), encoding: .utf8) {
            print(string)
            name = string
        } else {
            print("not a valid UTF-8 sequence")
            name = "Undefined"
        }
        data = Array(data.dropFirst(50))
        
        // A Node típus nevének a leszedése
        var typeName: String!
        if let string = String(data: Data(bytes: Array(data[0..<50])), encoding: .utf8) {
            print(string)
            typeName = string
        } else {
            print("not a valid UTF-8 sequence")
            typeName = "Undefined"
        }
        data = Array(data.dropFirst(50))
        
        let nodeID = Int(littleEndian: Data(bytes: Array(data[0..<8])).withUnsafeBytes { $0.pointee })
        data = Array(data.dropFirst(8))
        
        let weight = Int(littleEndian: Data(bytes: Array(data[0..<8])).withUnsafeBytes { $0.pointee })
        data = Array(data.dropFirst(8))
        
        let numberOfConnectedEdge = Int(littleEndian: Data(bytes: Array(data[0..<8])).withUnsafeBytes { $0.pointee })
        data = Array(data.dropFirst(8))
        
        let opTypeWeight = Int(littleEndian: Data(bytes: Array(data[0..<8])).withUnsafeBytes { $0.pointee })
        data = Array(data.dropFirst(8))
        
        let spectrum = Int(littleEndian: Data(bytes: Array(data[0..<8])).withUnsafeBytes { $0.pointee })
        data = Array(data.dropFirst(8))
        
        let startTime = Int(littleEndian: Data(bytes: Array(data[0..<8])).withUnsafeBytes { $0.pointee })
        data = Array(data.dropFirst(8))
        
        let type = Int(littleEndian: Data(bytes: Array(data[0..<8])).withUnsafeBytes { $0.pointee })
        data = Array(data.dropFirst(8))
        
        let parentID = Int(littleEndian: Data(bytes: Array(data[0..<8])).withUnsafeBytes { $0.pointee })
        data = Array(data.dropFirst(8))
        
        var _type: IO!
        switch type {
        case 0:
            _type = .Normal
        case 1:
            _type = .Input
        case 2:
            _type = .Output
        default:
            break
        }
        
        // Node típus felvétele a globális tömbbe
        var tmpNodeOpType: nodeOpType!
        if nodeOpTypeArray.contains(where: {
            if ($0 ).name == typeName {
                tmpNodeOpType = $0
                return true
            } else {
                return false
            }
            
        }) {
            
        } else {
            tmpNodeOpType = nodeOpType(name: typeName, defaultWeight: opTypeWeight)
            nodeOpTypeArray.append(tmpNodeOpType)
        }
        
        // Node létrehozása
        let tmpNode = Node(name: name, parent: nil, weight: weight, nodeOpType: tmpNodeOpType, nodeID: nodeID)
        tmpNode.spectrum = Double(spectrum)
        tmpNode.startTime = startTime
        tmpNode.type = _type
        
        // Node hozzáadása a NodeID : Node szótárhoz
        nodeID_Node[nodeID] = tmpNode
        nodeID_ParentID[nodeID] = parentID
        
        // Node hozzáadása az ideiglenes tömbhöz
        nodes.append(tmpNode)
    }
    
    func parseEdge(data: inout [UInt8]) {
        // Az Edge nevének leszedése
        var name: String!
        if let string = String(data: Data(bytes: Array(data[0..<50])), encoding: .utf8) {
            print(string)
            name = string
        } else {
            print("not a valid UTF-8 sequence")
            name = "Undefined"
        }
        data = Array(data.dropFirst(50))
        
        // Az Edge típus nevének a leszedése
        var dataTypeName: String!
        if let string = String(data: Data(bytes: Array(data[0..<50])), encoding: .utf8) {
            print(string)
            dataTypeName = string
        } else {
            print("not a valid UTF-8 sequence")
            dataTypeName = "Undefined"
        }
        data = Array(data.dropFirst(50))
        
        let edgeID = Int(littleEndian: Data(bytes: Array(data[0..<8])).withUnsafeBytes { $0.pointee })
        data = Array(data.dropFirst(8))
        
        let weight = Int(littleEndian: Data(bytes: Array(data[0..<8])).withUnsafeBytes { $0.pointee })
        data = Array(data.dropFirst(8))
        
        let typeWeight = Int(littleEndian: Data(bytes: Array(data[0..<8])).withUnsafeBytes { $0.pointee })
        data = Array(data.dropFirst(8))
        
        let parentSNodeID = Int(littleEndian: Data(bytes: Array(data[0..<8])).withUnsafeBytes { $0.pointee })
        data = Array(data.dropFirst(8))
        
        let parentDNodeID = Int(littleEndian: Data(bytes: Array(data[0..<8])).withUnsafeBytes { $0.pointee })
        data = Array(data.dropFirst(8))
        
        // Edge típus felvétele a globális tömbbe
        var tmpEdgeDataType: edgeDataType!
        if edgeDataTypeArray.contains(where: {
            if ($0 ).name == dataTypeName {
                tmpEdgeDataType = $0
                return true
            } else {
                return false
            }
            
        }) {
            
        } else {
            tmpEdgeDataType = edgeDataType(name: dataTypeName, defaultWeight: typeWeight)
            edgeDataTypeArray.append(tmpEdgeDataType)
        }
        
        // Edge létrehozása
        let tmpEdge = Edge(name: name, weight: weight, parentNode1: defaultParent, parentNode2: defaultParent, dataType: tmpEdgeDataType)
        tmpEdge.edgeID = edgeID
        
        // Edge hozzáadása a EdgeID : Edge szótárhoz
        edgeID_Edge[edgeID] = tmpEdge
        edgeID_sNodeID[edgeID] = parentSNodeID
        edgeID_dNodeID[edgeID] = parentDNodeID
        
        // Edge hozzáadása az ideiglenes tömbhöz
        edges.append(tmpEdge)
    }
    
    func fromFile(dataC: [UInt8]) {
        
        var data = dataC
        
        // Ellenőrizzük a fejlécet
        var header = [UInt8]()
        for i in 0..<12 {
            header.append(data[i])
        }
        let headerType: [UInt8] = [80, 114, 111, 32, 83, 121, 110, 116, 104, 0, 9, 1]
        if header == headerType {
            data = Array(data.dropFirst(12))
            Log?.Print(log: "A fáj beolvaása sikeres.", detailed: .High)
            print("A fáj beolvaása sikeres.")
            
            // Megnézzük, hogy összesen hány gráf van fájlban
            let allGroupsCount = UInt16(littleEndian: Data(bytes: Array(data[0..<2])).withUnsafeBytes { $0.pointee })
            data = Array(data.dropFirst(2))
            print("A gráfok összáma: \(allGroupsCount)")
            Log?.Print(log: "A gráfok összáma", detailed: .High)
            
            // Minden gráfra megcsináljuk:
            for i in 0..<allGroupsCount {
                // Felvesszük a nevét
                if let string = String(data: Data(bytes: Array(data[0..<50])), encoding: .utf8) {
                    print(string)
                } else {
                    print("not a valid UTF-8 sequence")
                }
                data = Array(data.dropFirst(50))
                
                // Lekérdezzük, hogy hány csoportja van
                let GroupCount = UInt16(littleEndian: Data(bytes: Array(data[0..<2])).withUnsafeBytes { $0.pointee })
                data = Array(data.dropFirst(2))
                print("A gráfok összáma\(GroupCount)")
                
                // Összeszedjük és példányosítjuk az összes csoportot
                for i in 0..<Int(GroupCount) {
                    parseGroup(data: &data)
                }
                
                // Lekérdezzük, hogy hány pontja van
                let NodeCount = UInt16(littleEndian: Data(bytes: Array(data[0..<2])).withUnsafeBytes { $0.pointee })
                data = Array(data.dropFirst(2))
                print("A pontok összszáma: \(NodeCount)")
                
                // Összeszedjük és példányosítjuk az összes pontot
                for i in 0..<Int(NodeCount) {
                    parseNode(data: &data)
                }
                
                // Lekérdezzük, hogy hány éle van
                let EdgeCount = UInt16(littleEndian: Data(bytes: Array(data[0..<2])).withUnsafeBytes { $0.pointee })
                data = Array(data.dropFirst(2))
                print("A gráfok élszáma\(EdgeCount)")
                
                // Összeszedjük és példányosítjuk az összes élt
                for i in 0..<Int(EdgeCount) {
                    parseEdge(data: &data)
                }
            }
            

            
        } else {
            Log?.Print(log: "A megnyitni kívánt fájl nem Pro Synth kompatibilis, vagy sérült.", detailed: .Low)
            print("A megnyitni kívánt fájl nem Pro Synth kompatibilis, vagy sérült.")
        }
        
    }
    
    
}
