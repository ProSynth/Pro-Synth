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
    
    init(into numOfParts: Int, with group: [GraphElement]) {
        self.sourceGroup = group
        self.numOfParts = numOfParts
        super.init()
    }
    
    
    func pushMatrix(groups: [GraphElement]) -> (matrix: [Double], sizeOfmatrix: Int, weight: [Int], nodeIDorder: [Int]) {
        
        var NodeIDs = [Int]()
        for i in 0..<groups.count {
            NodeIDs.append((groups[i] as! Node).nodeID)
        }
        
        var weight: [Int] = []
        let sizeOfMatrix : Int = groups.count
        /*for i in 0..<groups.count {             // Összeszámolja az összes pontot a gráfban
            sizeOfMatrix += groups[i].children.count
        }*/
        var Matrix: [Double] = Array(repeating: 0.0, count: sizeOfMatrix*sizeOfMatrix)
        Matrix.removeAll()
        for i in 0..<sizeOfMatrix*sizeOfMatrix {
            Matrix.append(0)
        }
        
        
        
        for i in 0..<groups.count {
            //for j in 0..<groups[i].children.count {
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
                    

                    
                    // Mi van, ha két pont között több él is van?
                }
            //}
        }
        
        
        
        for j in 0..<sizeOfMatrix {
            var rowSum : Double = 0
            for i in (j*sizeOfMatrix)..<((j+1)*sizeOfMatrix) {
                rowSum = rowSum + Matrix[i]
            }
            Matrix[j+(j*sizeOfMatrix)] = (-1)*rowSum
        }
        
        for i in 0..<sizeOfMatrix {
            for j in 0..<sizeOfMatrix {
                print("\(Matrix[i*sizeOfMatrix+j]), ",terminator:"")
            }
            print("\n")
        }
        
        return (Matrix, sizeOfMatrix, weight, NodeIDs)
    }
    
    func findFirstOutlerLoop(input: [GraphElement], startId: Int = 0) -> (outerLoop: [GraphElement], index: Int)? {
        
        for i in 0..<input.count {
            if (input[i] is Group) {
                switch (input[i] as! Group).loop {
                case .ACI:
                    let alert = NSAlert()
                    alert.messageText = "Hiba!!"
                    alert.informativeText = "Adatfüggő iteratív hurkot találtam :-( Ezt még nem tudom kezelni... Ezért leállok."
                    alert.addButton(withTitle: "OK")
                    return nil
                    break
                case .Normal:
                    print("Hurkot talált")
                    return (input[i].children, i)
                    break               // csinálni kell
                case .None:
                    print("Nem loopról van szó, de csoport")
                    break
                default:
                    break
                }
            }
        }
        return nil
    }
    
    
    func EdgeHandling(nodes: inout [GraphElement]) {
        // Do nothing
    }
    
    func Decomposition(into n: Int, with nodes: [GraphElement]) -> [GraphElement]? {
        var output = [GraphElement]()
        print("Dekompozíciót hajt végre")
        let sourceMatrix = pushMatrix(groups: nodes)
        var loopDecompose: WNCut = WNCut(sizeOfMatrix: sourceMatrix.sizeOfmatrix, sourceMatrix: sourceMatrix.matrix)
        let spectrum = loopDecompose.WNCut(weight: sourceMatrix.weight)
        
        let NodeIDKodtabla = spectrum.NodeIDCoder
        let NodeSpectrum = spectrum.Spectrum
        let NodeGroup = spectrum.Group
        let NodeIDOrder = sourceMatrix.nodeIDorder
        
        var NodeDictionary = [Int : Double]()
        
        var nodeCounter: Int = 0
        var nodeSpectrums = [Double]()
        
        for group in 1...(NodeGroup.max()!) {
            
            for i in 0..<NodeSpectrum.count {
                //print("\(i). ciklusban van benne")
                if NodeGroup[i] == group {
                    //print("Feltétel teljesül")
                    if NodeDictionary[NodeIDKodtabla[i]] != nil {                   // Ha létezik már olyan NodeID-jű pont, akkor átlagot veszünk
                        //print("Meglévő pont integrálása")
                        nodeSpectrums.append(NodeSpectrum[i])
                        nodeCounter += 1
                        let avg = (nodeSpectrums.reduce(0,+))/Double(nodeCounter)
                        NodeDictionary[NodeIDKodtabla[i]] = avg
                    } else {
                        //print("Új pont                        ÚJ!!!!")
                        NodeDictionary[NodeIDKodtabla[i]] = NodeSpectrum[i]
                        nodeSpectrums.removeAll()
                        nodeSpectrums.append(NodeSpectrum[i])
                        nodeCounter = 1
                    }
                    
                }
                
            }
            
            // Itt kell kezelni az összeömnlesztést
            
        }
        
        //let sortedNodeDictionary = NodeDictionary.sorted{ $0.value < $1.value }
        // Itt rendezzük őket sorrendbe, és kerülnek bele a szegmensekbe
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
            sumWeight += (nodes[sortedOriginalNodeDictionary[i].key] as! Node).weight
            segmentedNodeIDs.append(sortedOriginalNodeDictionary[i].key)
            
            

        }
        

        // Az élek itt rendeződnek át, új élek keletkeznek
        for j in 0..<nodes.count {
            for k in 0..<nodes[j].children.count {
                let edgeWeight = (nodes[j].children[k] as! Edge).weight
                let sNodeID = (nodes[j].children[k] as! Edge).parentsNode.nodeID
                let sNode = (nodes[j].children[k] as! Edge).parentsNode
                let dNodeID = (nodes[j].children[k] as! Edge).parentdNode.nodeID
                let dNode = (nodes[j].children[k] as! Edge).parentdNode
                let firstExist = (oldNewIDs[sNodeID] != nil)
                let secondExist = (oldNewIDs[dNodeID] != nil)

                if firstExist {
                    let ind = newIDIndex.index(of: oldNewIDs[sNodeID]!)!
                    output[ind].children.append(Edge(name: "Él", weight: edgeWeight, parentNode1: sNode, parentNode2: output[ind] as! Node))
                } else if secondExist {
                    let ind = newIDIndex.index(of: oldNewIDs[dNodeID]!)!
                    output[ind].children.append(Edge(name: "Él", weight: edgeWeight, parentNode1: output[ind] as! Node, parentNode2: dNode))
                    // A másik pontnál, ha nem jó a pushMatrix, lehet hiba
                } else if firstExist && secondExist {
                    if oldNewIDs[sNodeID] == oldNewIDs[dNodeID] {
                        // Ilyenkor nincsenek csak, elhagyjuk az élt
                    }
                    let ind1 = newIDIndex.index(of: oldNewIDs[sNodeID]!)!
                    let ind2 = newIDIndex.index(of: oldNewIDs[dNodeID]!)!
                    output[ind1].children.append(Edge(name: "Él", weight: edgeWeight, parentNode1: output[ind1] as! Node, parentNode2: output[ind1] as! Node))
                    output[ind2].children.append(Edge(name: "Él", weight: edgeWeight, parentNode1: output[ind1] as! Node, parentNode2: output[ind1] as! Node))
                } else if !firstExist && !secondExist {
                    // Nem ide tartozik az él, ennek hibának kellene lennie
                }
                
                
            }
        }
        
        if output.isEmpty {
            return nil
        } else {
            return output
        }
    }
    
    func SegmentedUnroll(group: inout [GraphElement], inaLoop: Bool) -> [GraphElement]? {
        
        var input: [GraphElement] = group
        var outputGraph: [GraphElement]? = nil
        var noLoops: Bool!
        var firstOuterLoop = findFirstOutlerLoop(input: group)

        
        if nil != firstOuterLoop {
            noLoops = false
            var firstOuterLoopGrap = (firstOuterLoop?.outerLoop)!
            var firstOuterLoopIndex = (firstOuterLoop?.index)!
            while !noLoops {
                tmp = SegmentedUnroll(group: &firstOuterLoopGrap, inaLoop: true)!
                
                // új szegmensek beillesztése eggyel feljebb
                let loopCount: Int = 1       // Azt, hogy hányszor fut le a hurok, még be kell állítani
                for j in 0..<loopCount {
                    for i in 0..<tmp.count {
                        input.append(tmp[i])
                    }
                }
                group.remove(at: firstOuterLoopIndex)       // Hibás lehet az index
                EdgeHandling(nodes: &group)                 // ÉLkezelést meg kell csinálni
                
                
                // megnézzük, hogy ugyanazon a szinten van-e még loop
                firstOuterLoop = findFirstOutlerLoop(input: group, startId: firstOuterLoopIndex)

                
                if nil != firstOuterLoop {
                    noLoops = false
                    firstOuterLoopGrap = (firstOuterLoop?.outerLoop)!
                    firstOuterLoopIndex = (firstOuterLoop?.index)!
                } else {
                    noLoops = true
                }
            }
        } else {
            noLoops = true
            if inaLoop {
                outputGraph = Decomposition(into: numOfParts, with: input)
                guard nil != outputGraph else {
                    let alert = NSAlert()
                    alert.messageText = "Hiba!"
                    alert.informativeText = "Nem sikerült végrehajtani a dekompozíciót"
                    alert.addButton(withTitle: "Ez van..")
                    return nil
                }
            } else {
                outputGraph = input
            }
        }
        

        
        

        return outputGraph
    }
    
    func DoProcess() -> [GraphElement]? {
        let destinationGraph = SegmentedUnroll(group: &sourceGroup, inaLoop: false)
        guard nil != destinationGraph else {
            print("Nem sikerült a szintézis")
            return nil
        }
        return destinationGraph
    }
}

