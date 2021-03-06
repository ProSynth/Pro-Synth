//
//  RSCU_LoopUnroller.swift
//  Pro Synth
//
//  Created by Markovits Gergő on 2017. 11. 08..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

class RSCU_LoopUnroller: NSObject {
    
    private var sourceGroup: [GraphElement]
    private var tmp: [GraphElement]!
    private var numOfParts: Int
    var recursionDepth: Int
    
    init(into numOfParts: Int, with group: [GraphElement]) {
        self.sourceGroup = group
        self.numOfParts = numOfParts
        self.recursionDepth = 0
        super.init()
    }
    
    
    func pushMatrix(groups: [GraphElement]) -> (matrix: [Double], sizeOfmatrix: Int, weight: [Int], nodeIDorder: [Int]) {
        print("Hurokkezelő: Mátrixxá alakítás..")
        Log?.Print(log: "## Hurokkezelő: Mátrixxá alakítás..", detailed: .Normal)
        var NodeIDs = [Int]()
        for i in 0..<groups.count {
            NodeIDs.append((groups[i] as! Node).nodeID)
        }
        
        var weight: [Int] = []
        let sizeOfMatrix : Int = groups.count
        var Matrix: [Double] = Array(repeating: 0.0, count: sizeOfMatrix*sizeOfMatrix)
        Matrix.removeAll()
        for i in 0..<sizeOfMatrix*sizeOfMatrix {
            Matrix.append(0)
        }
        
        
        
        for i in 0..<groups.count {
           
                let currentWeight = (groups[i] as! Node).weight
                if currentWeight > 1 {
                    weight.append(currentWeight)
                } else {
                    weight.append(1)
                }
                for k in 0..<groups[i].children.count {
                    let parent1 = (groups[i].children[k] as! Edge).parentsNode
                    let parent2 = (groups[i].children[k] as! Edge).parentdNode
                    var newID1: Int!
                    var newID2: Int!
                    if NodeIDs.contains(parent1.nodeID) {
                        newID1 = NodeIDs.index(of: parent1.nodeID)
                    }
                    if NodeIDs.contains(parent2.nodeID) {
                        newID2 = NodeIDs.index(of: parent2.nodeID)
                    }
                    if (nil != newID1) && (nil != newID2) {
                        Matrix[newID2*sizeOfMatrix + newID1] = (-1*(Double((groups[i].children[k] as! Edge).weight)))
                        Matrix[newID1*sizeOfMatrix + newID2] = (-1*(Double((groups[i].children[k] as! Edge).weight)))
                    }
                    

                    
                }
           
        }
        
        
        
        for j in 0..<sizeOfMatrix {
            var rowSum : Double = 0
            for i in (j*sizeOfMatrix)..<((j+1)*sizeOfMatrix) {
                rowSum = rowSum + Matrix[i]

            }
            Matrix[j+(j*sizeOfMatrix)] = (-1)*rowSum
            if rowSum == 0 {
                print("Már a mátrixpusholónál 0 van a főátlóban \(j)")
                Log?.Print(log: "## Hurokkezelő: Hiba történt a mátrix készítésénél, a \(j) sorban.", detailed: .Low)
            }
        }
        return (Matrix, sizeOfMatrix, weight, NodeIDs)
    }
    
    func findFirstOutlerLoop(input: [GraphElement], startId: Int = 0) -> (outerLoop: [GraphElement], index: Int, loopCount: Int)? {
        
        for i in 0..<input.count {
            if (input[i] is Group) {
                switch (input[i] as! Group).loop {
                case .ACI:
                    let alert = NSAlert()
                    alert.messageText = "Hiba!!"
                    alert.informativeText = "Adatfüggő iteratív hurkot találtam :-( Ezt még nem tudom kezelni... Ezért leállok."
                    alert.addButton(withTitle: "OK")
                    alert.runModal()
                    return nil
                case .Normal:
                    print("Hurokkezelő: Hurkot talált")
                    DispatchQueue.main.async {
                        Log?.Print(log: "## Hurokkezelő: Hurkot talált.", detailed: .Low)
                    }
                    return (input[i].children, i, (input[i] as! Group).loopCount!)
                case .None:
                    print("Hurokkezelő: Csoportot talált")
                     Log?.Print(log: "## Hurokkezelő: Csoportot talált.", detailed: .Normal)
                    break
                default:
                    break
                }
            }
        }
        return nil
    }
    
    
    func Decomposition(into n: Int, with nodes: [GraphElement], LoopCount times: Int = 1) -> [GraphElement]? {
        
        print("Hurokkezelő: Hurok kitekerése folyamatban..")
        Log?.Print(log: "## Hurokkezelő: Hurok kitekerése folyamatban..", detailed: .Low)
        var multipliedGraph = [GraphElement]()
        for i in 0..<nodes.count {
            multipliedGraph.append(nodes[i])
        }
        
        var loopCount = times
        var copyIndexIDTable = [Int]()
        var Edges = [Edge]()
        let until = multipliedGraph.count
        
        for i in 0..<nodes.count {
            for j in 0..<multipliedGraph[i].children.count {
                Edges.append(multipliedGraph[i].children[j] as! Edge)
            }
        }
        
        
        
        for k in 0..<loopCount-1 {
            let offseft: Int = multipliedGraph.count
            for i in 0..<nodes.count {
                let name = multipliedGraph[i].name
                let id = (multipliedGraph[i] as! Node).nodeID
                let weight = (multipliedGraph[i] as! Node).weight
                multipliedGraph.append(Node(name: name, parent: nil, weight: weight, nodeOpType: nil))
                copyIndexIDTable.append(id)
            }
            
            for i in 0..<Edges.count {
                let tmpDNode = Edges[i].parentdNode
                let tmpDNodeID = Edges[i].parentdNode.nodeID
                let tmpSNode = Edges[i].parentsNode
                let tmpSNodeID = Edges[i].parentsNode.nodeID
                let name = Edges[i].name
                let weight = Edges[i].weight
                var newDParentIndex: Int!
                var newSParentIndex: Int!
                var SExist: Bool = false
                var DExist: Bool = false
                if copyIndexIDTable.contains(tmpDNodeID) {
                    DExist = true
                }
                if copyIndexIDTable.contains(tmpSNodeID) {
                    SExist = true
                }
                if DExist && SExist {
                    newDParentIndex = copyIndexIDTable.index(of: tmpDNodeID)! + offseft
                    newSParentIndex = copyIndexIDTable.index(of: tmpSNodeID)! + offseft
                    let tmpEdge = Edge(name: name, weight: weight, parentNode1: multipliedGraph[newSParentIndex] as! Node, parentNode2: multipliedGraph[newDParentIndex] as! Node, dataType: Edges[i].type)
                    multipliedGraph[newDParentIndex].children.append(tmpEdge)
                    multipliedGraph[newSParentIndex].children.append(tmpEdge)
                } else if SExist {
                    newSParentIndex = copyIndexIDTable.index(of: tmpSNodeID)! + offseft
        
                    let tmpEdge = Edge(name: name, weight: weight, parentNode1: multipliedGraph[newSParentIndex] as! Node, parentNode2: tmpDNode, dataType: Edges[i].type )
                    multipliedGraph[newSParentIndex].children.append(tmpEdge)
                    tmpDNode.children.append(tmpEdge)
                } else if DExist {
                    newDParentIndex = copyIndexIDTable.index(of: tmpDNodeID)! + offseft
                    let tmpEdge = Edge(name: name, weight: weight, parentNode1: tmpSNode , parentNode2: multipliedGraph[newDParentIndex] as! Node, dataType: Edges[i].type)
                    multipliedGraph[newDParentIndex].children.append(tmpEdge)
                    tmpSNode.children.append(tmpEdge)
                } else {
                    // Hiba
                    print("Hurokkezelő: Hiba a ciklus többszörözésében!")
                    Log?.Print(log: "## Hurokkezelő: Hiba a ciklus többszörözésében!", detailed: .Low)
                }
                
            }
            //outpIndexOldID.removeAll()
            copyIndexIDTable.removeAll()
        }
        
        
        var output = [GraphElement]()
        print("Hurokkezelő: Dekompozíció folyamatban..")
        Log?.Print(log: "## Hurokkezelő: Dekompozíció folyamatban..", detailed: .Low)
        let sourceMatrix = pushMatrix(groups: multipliedGraph)
        var loopDecompose: WNCut = WNCut(sizeOfMatrix: sourceMatrix.sizeOfmatrix, sourceMatrix: sourceMatrix.matrix)
        let spectrum = loopDecompose.FastWNCut(weight: sourceMatrix.weight)
        
        let NodeIDKodtabla = spectrum.NodeIDCoder
        let NodeSpectrum = spectrum.Spectrum
        let NodeGroup = spectrum.Group
        let NodeIDOrder = sourceMatrix.nodeIDorder
        
        var NodeDictionary = [Int : Double]()
        
        var nodeCounter: Int = 0
        var nodeSpectrums = [Double]()
        
     
        
        for i in 0..<NodeSpectrum.count {

            if NodeDictionary[NodeIDKodtabla[i]] != nil {                   // Ha létezik már olyan NodeID-jű pont, akkor átlagot veszünk
                
                nodeSpectrums.append(NodeSpectrum[i])
                nodeCounter += 1
                let avg = (nodeSpectrums.reduce(0,+))/Double(nodeCounter)
                NodeDictionary[NodeIDKodtabla[i]] = avg
            } else {
                
                NodeDictionary[NodeIDKodtabla[i]] = NodeSpectrum[i]
                nodeSpectrums.removeAll()
                nodeSpectrums.append(NodeSpectrum[i])
                nodeCounter = 1
            }
            
     
            
        }
        

        var originalNodeIDDictionary = [Int : Double]()
        
        for i in 0..<NodeDictionary.count {
            originalNodeIDDictionary[NodeIDOrder[i]] = NodeDictionary[i]
        }
        
        var oldNewIDs = [Int : Int]()           // Régi ID, új ID
        var newIDIndex = [Int]()                // Index az új ID-hoz az outputba
        
        let ct = originalNodeIDDictionary.count/n
        let sortedOriginalNodeDictionary = originalNodeIDDictionary.sorted{ $0.value < $1.value }
        
        var counter: Int = 0
        var sum: Double = 0
        var sumWeight: Int = 0
        var segmentedNodeIDs = [Int]()
        for i in 0..<sortedOriginalNodeDictionary.count {


            
            if (counter == ct-1) {
                
                let avg = sum / Double(ct)

                output.append(Node(name: "InternalElement\(i)", parent: nil, weight: sumWeight, nodeOpType: nil))
                
                (output.last as! Node).spectrum = avg
                let newNodeID = (output.last as! Node).nodeID
                newIDIndex.append(newNodeID)
                for j in 0..<segmentedNodeIDs.count {
                    oldNewIDs[segmentedNodeIDs[j]] = newNodeID
                }
                
                
                // Reinit
                sum = 0
                counter = 0
                sumWeight = 0
                segmentedNodeIDs.removeAll()
            }
            

            
            sum += sortedOriginalNodeDictionary[i].value
            let ID = sortedOriginalNodeDictionary[i].key
            
            sumWeight += (multipliedGraph[NodeIDOrder.index(of: ID)!] as! Node).weight
            segmentedNodeIDs.append(sortedOriginalNodeDictionary[i].key)
            
            
            counter += 1
        }
        
        print("Hurokkezelő: Élek átrendezése az új szegmensekhez folyamatban..")
        Log?.Print(log: "## Hurokkezelő: Élek átrendezése az új szegmensekhez folyamatban..", detailed: .Low)

        // Az élek itt rendeződnek át, új élek keletkeznek
        for j in 0..<multipliedGraph.count {
            Log?.Print(log: "## Hurokkezelő: Élek átrendezése \(j+1)/\(multipliedGraph.count) kész.", detailed: .High)
            for k in 0..<multipliedGraph[j].children.count {
                let edgeWeight = (multipliedGraph[j].children[k] as! Edge).weight
                let sNodeID = (multipliedGraph[j].children[k] as! Edge).parentsNode.nodeID
                let sNode = (multipliedGraph[j].children[k] as! Edge).parentsNode
                let dNodeID = (multipliedGraph[j].children[k] as! Edge).parentdNode.nodeID
                let dNode = (multipliedGraph[j].children[k] as! Edge).parentdNode
                let dataType = (multipliedGraph[j].children[k] as! Edge).type

                let firstExist = (oldNewIDs[sNodeID] != nil)
                let secondExist = (oldNewIDs[dNodeID] != nil)

                if firstExist && secondExist {
                    if oldNewIDs[sNodeID] == oldNewIDs[dNodeID] {
                        // Ilyenkor nincsenek csak, elhagyjuk az élt
                    }
                    let ind1 = newIDIndex.index(of: oldNewIDs[sNodeID]!)!
                    let ind2 = newIDIndex.index(of: oldNewIDs[dNodeID]!)!
                    output[ind1].children.append(Edge(name: "Él", weight: edgeWeight, parentNode1: output[ind1] as! Node, parentNode2: output[ind1] as! Node, dataType: dataType))
                    output[ind2].children.append(Edge(name: "Él", weight: edgeWeight, parentNode1: output[ind1] as! Node, parentNode2: output[ind1] as! Node, dataType: dataType))
                 } else if firstExist {
                    let ind = newIDIndex.index(of: oldNewIDs[sNodeID]!)!
                    output[ind].children.append(Edge(name: "Él", weight: edgeWeight, parentNode1: output[ind] as! Node, parentNode2: dNode, dataType: dataType))
                    dNode.children.append(Edge(name: "Él", weight: edgeWeight, parentNode1: output[ind] as! Node, parentNode2: dNode, dataType: dataType))
                 } else if secondExist {
                    let ind = newIDIndex.index(of: oldNewIDs[dNodeID]!)!
                    output[ind].children.append(Edge(name: "Él", weight: edgeWeight, parentNode1: sNode, parentNode2: output[ind] as! Node, dataType: dataType))
                    sNode.children.append(Edge(name: "Él", weight: edgeWeight, parentNode1: sNode, parentNode2: output[ind] as! Node, dataType: dataType))
                } else if !firstExist && !secondExist {
                    // Nem ide tartozik az él, ennek hibának kellene lennie
                }
                
                
            }
            
        }
        
        
        if output.isEmpty {
            print("Hurokkezelő: A dekompozíció és szegmensek rendezése közben hibát talált az algoritmus, az j szegmensek nem jöttek létre")
            Log?.Print(log: "## Hurokkezelő: A dekompozíció és szegmensek rendezése közben hibát talált az algoritmus, az j szegmensek nem jöttek létreó!", detailed: .Low)
            return nil
        } else {
            
            print("Hurokkezelő: Dekompozíció befejezve.")
            Log?.Print(log: "## Hurokkezelő: Dekompozíció befejezve.", detailed: .Low)
            return output
        }
    }
    
    func SegmentedUnroll(group: [GraphElement], inaLoop: Bool = false, loopCount: Int = 0) -> [GraphElement]? {
        
        var input: [GraphElement] = group
        var outputGraph: [GraphElement]? = nil
        var noLoops: Bool!
        var firstOuterLoop = findFirstOutlerLoop(input: input)
        
        if nil != firstOuterLoop {
            recursionDepth += 1
            noLoops = false
            var firstOuterLoopGrap = (firstOuterLoop?.outerLoop)!
            var firstOuterLoopIndex = (firstOuterLoop?.index)!
            var fristOuterLoopCount = (firstOuterLoop?.loopCount)!
            while !noLoops {
                tmp = SegmentedUnroll(group: firstOuterLoopGrap, inaLoop: true, loopCount: fristOuterLoopCount)!
                print("Hurokkezelő: Kibontás folyamatban...")
                Log?.Print(log: "## Hurokkezelő: Kibontás folyamatban...", detailed: .Low)

                
                for i in 0..<tmp.count {
                    input.append(tmp[i])
                }
                
                input.remove(at: firstOuterLoopIndex)       // Hibás lehet az index
            
    
                // megnézzük, hogy ugyanazon a szinten van-e még loop
                firstOuterLoop = findFirstOutlerLoop(input: input, startId: firstOuterLoopIndex)

                
                if nil != firstOuterLoop {
                    noLoops = false
                    firstOuterLoopGrap = (firstOuterLoop?.outerLoop)!
                    firstOuterLoopIndex = (firstOuterLoop?.index)!
                    fristOuterLoopCount = (firstOuterLoop?.loopCount)!
                } else {
                    noLoops = true
                }
            }
        } else {
            noLoops = true
            
        }
        
        if inaLoop {
            //let loopCount: Int = 1       // Azt, hogy hányszor fut le a hurok, még be kell állítani
            outputGraph = Decomposition(into: numOfParts, with: input, LoopCount: loopCount)
            guard nil != outputGraph else {
                print("A rekurzív függvény visszatérési értéke nil")
                Log?.Print(log: "## Hurokkezelő: A rekurzív függvény visszatérési értéke nil!", detailed: .Low)
                let alert = NSAlert()
                alert.messageText = "Hiba!"
                alert.informativeText = "Nem sikerült végrehajtani a dekompozíciót"
                alert.addButton(withTitle: "Ez van..")
                return nil
            }
        } else {
            outputGraph = input
        }
        
        

        return outputGraph
    }
    
    func DoProcess() -> [GraphElement]? {
        var destinationGraph: [GraphElement]?
       
            let destinationGraphLoc = self.SegmentedUnroll(group: self.sourceGroup)
        
                destinationGraph = destinationGraphLoc
                
                
                guard nil != destinationGraph else {
                    print("Nem sikerült a szintézis")
                    Log?.Print(log: "## Hurokkezelő: Nem sikerült a szintézis!", detailed: .Low)
                    return nil
                }
                Log?.Print(log: "## Hurokkezelő: A szintézis elkészült.", detailed: .Low)
                return destinationGraph
        
        
        

        
        
    }
 
    /*
    func DoProcess(onComplete: @escaping ([GraphElement]?)->()) {
        var destinationGraph: [GraphElement]?
        DispatchQueue.global(qos: .userInitiated).async {
            let destinationGraphLoc = self.SegmentedUnroll(group: self.sourceGroup)
            destinationGraph = destinationGraphLoc
            
            guard nil != destinationGraph else {
                print("Nem sikerült a szintézis")
                Log?.Print(log: "## Hurokkezelő: Nem sikerült a szintézis!", detailed: .Low)
                onComplete(nil)
                return
            }
            Log?.Print(log: "## Hurokkezelő: A szintézis elkészült.", detailed: .Low)
            onComplete(destinationGraph)
            
        }
        
        
        
        
    }*/
}

