//
//  RSCU_LoopUnroller.swift
//  Pro Synth
//
//  Created by Markovits Gergő on 2017. 11. 08..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

class RSCU_LoopUnroller: NSObject {
    
    private var group: [GraphElement]
    private var tmp: [GraphElement]
    
    init(group: [GraphElement]) {
        self.group = group
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
                    
                    Matrix[newID2*sizeOfMatrix + newID1] = (-1*(Double((groups[i].children[k] as! Edge).weight)))
                    Matrix[newID1*sizeOfMatrix + newID2] = (-1*(Double((groups[i].children[k] as! Edge).weight)))
                    
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
                    return (input[i].children, i)
                    break               // csinálni kell
                case .None:
                    break
                default:
                    break
                }
            }
        }
        return nil
    }
    
    func DoDecomposition(NodeSpectrum: [Double], NodeGroup: [Int], NodeIDKodtabla: [Int], NodeIDOrig: [Int], param: Int) -> [GraphElement] {
        
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
            // Ezutána  Dictionaryban már az eredeti NodeID-hez tartozó spektrumok vannak
            for i in 0..<NodeDictionary.count {
                let tmp = NodeDictionary[i]
                NodeDictionary.removeValue(forKey: i)
                NodeDictionary[NodeIDOrig[i]] = tmp
            }

            // Itt kell kezelni az összeömnlesztést

        }
        
        
        
    }
    
    func SegmentedUnroll(group: [GraphElement], inaLoop: Bool) -> [GraphElement]? {
        
        var input: [GraphElement] = group
        var noLoops: Bool!
        var firstOuterLoop = findFirstOutlerLoop(input: group)
        
        if nil != firstOuterLoop {
            noLoops = false
        } else {
            noLoops = true
        }
        
        while !noLoops {
            tmp = SegmentedUnroll(group: (firstOuterLoop?.outerLoop)!, inaLoop: true)!
            for i in 0..<tmp.count {
                input.append(tmp[i])
            }
            input.remove(at: (firstOuterLoop?.index)!)
            firstOuterLoop = findFirstOutlerLoop(input: input, startId: (firstOuterLoop?.index)!)
        }
        
        if inaLoop {
            let inputVolt = input
            let sourceMatrix = pushMatrix(groups: input)
            var loopDecompose: WNCut = WNCut(sizeOfMatrix: sourceMatrix.sizeOfmatrix, sourceMatrix: sourceMatrix.matrix)
            let spectrum = loopDecompose.WNCut(weight: sourceMatrix.weight)
            
        }
        

        
        
        
    }
    
    func DoProcess(e: Int) -> [GraphElement] {
        <#function body#>
    }
}

extension Array {
    func splitBy(_ chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map({ (startIndex) -> [Element] in
            let endIndex = (startIndex.advanced(by: chunkSize) > self.count) ? self.count-startIndex : chunkSize
            return Array(self[startIndex..<startIndex.advanced(by: endIndex)])
        })
    }
}
