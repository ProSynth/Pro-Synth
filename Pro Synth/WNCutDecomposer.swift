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
    
    var plus: Int = 0
    
    func checkIfBothNodeIdInArray(edge: Edge, indexes: [Int], sourceNodes: [Node]) -> Bool {
        //edge.parentNode2.nodeID
        var cond1: Bool = false
        var cond2: Bool = false
        for i in 0..<indexes.count {
            cond1 = edge.parentNode1.nodeID == sourceNodes[indexes[i]].nodeID
            if cond1 { break }
        }
        for i in 0..<indexes.count {
            cond2 = edge.parentNode2.nodeID == sourceNodes[indexes[i]].nodeID
            if cond2 { break }
        }
        if (cond1 && cond2) {
            print("Nem kerül be")
            plus += 1
            return true
        }
        return false
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
            
            // Itt kell elvégezni a sorbarendezést, stb-t
            
            let sortedNodeDictionary = NodeDictionary.sorted{ $0.value < $1.value }
            let min = (sortedNodeDictionary.first!).value
            let max = (sortedNodeDictionary.last!).value
            
            var runningPoint: Double = min
            let maxDistence = (max-min)*(p/1000)
            
            
            // A kimeneti gráf struktúra feltöltése
            destinationGroups.append(Group(name: "Group #\(group)", maxGroupTime: 0))           // Az adott, diszjunkt csoport létrehozása
            

            var indexes = [Int]()
            var prevIndex: Int? = nil
            
            for i in 0..<sortedNodeDictionary.count {
                guard let index = findNode(fromID: sortedNodeDictionary[i].key, nodes: sourceNodes) else {
                    print("Hiba az ID alapú meghatározásnál, nem találta a pontot")
                    return nil
                }
                
                //print("\(index) sorszámú pontot megtaláltam")
                let name = (sourceNodes[index] as GraphElement).name

                //let weight = sourceNodes[index].weight
                
                if runningPoint > sortedNodeDictionary[i].value {
                    (destinationGroups[group-1].children.last as! Node).weight += 1
                    destinationGroups[group-1].children.last?.name += ":\(name)"
                    runningPoint = sortedNodeDictionary[i].value
                } else {
                    
                    if prevIndex != nil {
                        for j in 0..<indexes.count {
                            for edge in 0..<(sourceNodes[indexes[j]] as GraphElement).children.count {
                                let  theEdge = ((sourceNodes[indexes[j]] as GraphElement).children[edge] as! Edge)
                                if (!checkIfBothNodeIdInArray(edge: theEdge, indexes: indexes, sourceNodes: sourceNodes)) {
                                    (destinationGroups[group-1].children.last!).children.append((sourceNodes[indexes[j]] as GraphElement).children[edge] as! Edge)
                                }
                            }
                            
                            
                        }
                    }
                    
                    
                    
                    destinationGroups[group-1].children.append(Node(name: name, weight: 1, nodeOpType: .none))
                    // Élek hozzáadása

                    indexes.removeAll()
                    runningPoint = sortedNodeDictionary[i].value
                }
                
                
                

                indexes.append(index)                           // Az összetartozó pontok indexe

                
                runningPoint += maxDistence
                
                prevIndex = index
            }
            
            for j in 0..<indexes.count {
                for edge in 0..<(sourceNodes[indexes[j]] as GraphElement).children.count {
                    let  theEdge = ((sourceNodes[indexes[j]] as GraphElement).children[edge] as! Edge)
                    if (!checkIfBothNodeIdInArray(edge: theEdge, indexes: indexes, sourceNodes: sourceNodes)) {
                        (destinationGroups[group-1].children.last!).children.append((sourceNodes[indexes[j]] as GraphElement).children[edge] as! Edge)
                    }
                }
            }
            
            //Töröljük a tartalmát, hogy legközelebb üres legyen
            NodeDictionary.removeAll()
        }

        
        
        print("\(plus)")
        
        
        return destinationGroups
    }
    

}
