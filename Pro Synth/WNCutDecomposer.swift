//
//  WNCutDecomposer.swift
//  Pro Synth
//
//  Created by Markovits Gergő on 2017. 11. 08..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa



class WNCutDecomposer: NSObject {

    override init() {
        super.init()
    }
    
    func pushMatrix(groups: [GraphElement]) -> (matrix: [Double], sizeOfmatrix: Int, weight: [Int]) {
        
        var weight: [Int] = []
        var sizeOfMatrix : Int = 0
        for i in 0..<groups.count {             // Összeszámolja az összes pontot a gráfban
            sizeOfMatrix += groups[i].children.count
        }
        var Matrix: [Double] = Array(repeating: 0.0, count: sizeOfMatrix*sizeOfMatrix)
        Matrix.removeAll()
        for i in 0..<sizeOfMatrix*sizeOfMatrix {
            Matrix.append(0)
        }
        
        
        for i in 0..<groups.count {
            for j in 0..<groups[i].children.count {
                let currentWeight = (groups[i].children[j] as! Node).weight
                if currentWeight > 1 {
                    weight.append(currentWeight)
                } else {
                    weight.append(1)
                }
                for k in 0..<groups[i].children[j].children.count {
                    let parent1 = (groups[i].children[j].children[k] as! Edge).parentNode1
                    let parent2 = (groups[i].children[j].children[k] as! Edge).parentNode2
                    
                    
                    Matrix[parent2.nodeID*sizeOfMatrix + parent1.nodeID] = (-1*(Double((groups[i].children[j].children[k] as! Edge).weight)))
                    Matrix[parent1.nodeID*sizeOfMatrix + parent2.nodeID] = (-1*(Double((groups[i].children[j].children[k] as! Edge).weight)))
                    
                    // Mi van, ha két pont között több él is van?
                }
            }
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
        
        return (Matrix, sizeOfMatrix, weight)
    }
    
    func findNode(fromID: Int, nodes: [Node]) -> Int? {
        for i in 0..<nodes.count {
            if nodes[i].nodeID == fromID {
                return i
            }
        }
        return nil
    }
    
    
    
    func DoProcess(sourceGroups: [GraphElement], p:Double) -> [GraphElement]? {
        
        var destinationGroups = [GraphElement]()
        
        var sourceNodes = [Node]()
        for group in 0..<sourceGroups.count {
            for node in 0..<sourceGroups[group].children.count {
                sourceNodes.append(sourceGroups[group].children[node] as! Node)
            }
        }

        let matrixStruct = pushMatrix(groups: sourceGroups)
        let synthesis: WNCut = WNCut(sizeOfMatrix: matrixStruct.sizeOfmatrix, sourceMatrix: matrixStruct.matrix)
        let spectrum = synthesis.WNCut(weight: matrixStruct.weight)

        let NodeIDKodtabla = spectrum.NodeIDCoder
        let NodeSpectrum = spectrum.Spectrum
        let NodeGroup = spectrum.Group
        
        var NodeDictionary = [Int : Double]()
        

        
        for group in 1...(NodeGroup.max()!) {
            
            // A kibővített gráf leredukálása, így már egészen biztos, hogy egy nodeID-hoz a vektor egyetlen eleme, és egyetlen spetruma fog tartozni
            var nodeCounter: Int = 0
            var nodeSpectrums = [Double]()
            for i in 0..<NodeSpectrum.count {
                if NodeGroup[i] == group {
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
            }
            
            // Itt kell elvégezni a sorbarendezést, stb-t
            
            let sortedNodeDictionary = NodeDictionary.sorted{ $0.value < $1.value }
            let min = (sortedNodeDictionary.first!).value
            let max = (sortedNodeDictionary.last!).value
            
            var runningPoint: Double = min
            let maxDistence = (max-min)*(p/100)
            
            
            // A kimeneti gráf struktúra feltöltése
            destinationGroups.append(Group(name: "Group #\(group)", maxGroupTime: 0))           // Az adott, diszjunkt csoport létrehozása
            
            guard let index = findNode(fromID: sortedNodeDictionary[0].key, nodes: sourceNodes) else {
                print("Hiba az ID alapú meghatározásnál, nem találta a pontot")
                return nil
            }
            
            //let index = findNode(fromID: sortedNodeDictionary[0].key, nodes: sourceNodes)
            let name = (sourceNodes[index] as GraphElement).name
            //let weight = sourceNodes[index].weight
            destinationGroups[group-1].children.append(Node(name: name, weight: 1, nodeOpType: nil, nodeID: sortedNodeDictionary[0].key))
            runningPoint += maxDistence
            
            for i in 1..<sortedNodeDictionary.count {
                guard let index = findNode(fromID: sortedNodeDictionary[0].key, nodes: sourceNodes) else {
                    print("Hiba az ID alapú meghatározásnál, nem találta a pontot")
                    return nil
                }
                let name = (sourceNodes[index] as GraphElement).name
                //let weight = sourceNodes[index].weight
                
                if runningPoint > sortedNodeDictionary[i].value {
                    (destinationGroups[group-1].children.last as! Node).weight += 1
                    destinationGroups[group-1].children.last?.name += ":\(name)"
                    runningPoint = sortedNodeDictionary[i].value
                } else {
                    destinationGroups[group-1].children.append(Node(name: name, weight: 1, nodeOpType: nil))
                    runningPoint = sortedNodeDictionary[i].value
                }
                
                runningPoint += maxDistence
                
                
            }
            
            
            
            //Töröljük a tartalmát, hogy legközelebb üres legyen
            NodeDictionary.removeAll()
        }

        
        
        
        
        
        return destinationGroups
    }
    

}
