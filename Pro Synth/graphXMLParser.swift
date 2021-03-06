//
//  graphXMLParser.swift
//  Pro Synth
//
//  Created by Markovits Gergő on 2017. 11. 18..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

class graphXMLParser: NSObject, XMLParserDelegate {
    var groups = [GraphElement]()
    
    var tmpGraphGroups = [[GraphElement]]()
    var tmpGroup = [GraphElement]()
    var nodeForEdge = [Node]()
    var parentGroup: Group?
    
    var indexTable = [Int : Int]()
    
    var tmpNode: Node!
    
    var tmpName: String = ""
    var tmpId: Int = 0
    var tmpWeight: Int = 0
    var tmpCount: Int = 0
    
    var firstEog: Bool = true
    
    private var parserCompletionHandler: (([GraphElement]) -> Void)?
    
    func parseFeed(url: URL, completionHandler: (([GraphElement]) -> Void)?)  {
        self.parserCompletionHandler = completionHandler
        
        let request = URLRequest(url: url)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                if let error = error {
                    print(error.localizedDescription)
                }
                return
            }
            
            // Parse
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
        }
        
        task.resume()
        
    }
    
    func parseNode(attributes attributeDict: [String : String] = [:]) {
        var lType: LoopType
        var tmpLocalGroup: Group!
        if let type = attributeDict["class"] {
            switch type {
            case "function":
                if let name = attributeDict["name"] {
                    tmpName = name
                }
                tmpLocalGroup = Group(name: tmpName, parent: parentGroup, maxGroupTime: 0)
                tmpGroup.append(tmpLocalGroup)
                parentGroup = tmpLocalGroup
                break
            case "loop":
                if let id = attributeDict["id"] {
                    if let c = Int(id) {
                        tmpId = c
                    }
                }
                if let id = attributeDict["count"] {
                    if let c = Int(id) {
                        tmpCount = c
                        lType = .Normal
                    } else {
                        lType = .ACI
                    }
                    
                } else {
                    lType = .ACI
                }
                tmpLocalGroup = Group(name: "Loop", parent: parentGroup, maxGroupTime: 0, groupID: tmpId, loop: lType)
                tmpLocalGroup.loopCount = tmpCount
                tmpGroup.append(tmpLocalGroup)
                parentGroup = tmpLocalGroup
                break
            default:
                if let name = attributeDict["ctype"] {
                    tmpName = name
                } else if let name = attributeDict["type"] {
                    tmpName = name
                }
                if let id = attributeDict["id"] {
                    if let c = Int(id) {
                        tmpId = c
                    }
                }
                if let id = attributeDict["latency"] {
                    if let c = Int(id) {
                        tmpWeight = c
                    }
                }
                
                var tmpNodeOpType: nodeOpType!
                if nodeOpTypeArray.contains(where: {
                    if ($0 ).name == tmpName {
                        tmpNodeOpType = $0
                        return true
                    } else {
                        return false
                    }
                    
                }) {
                    
                } else {
                    tmpNodeOpType = nodeOpType(name: tmpName, defaultWeight: tmpWeight)
                    nodeOpTypeArray.append(tmpNodeOpType)
                }
                
                tmpNode = Node(name: tmpName, parent: parentGroup, weight: tmpWeight, nodeOpType: tmpNodeOpType, nodeID: tmpId)       // Hol a pontsúly?
                tmpGroup.append(tmpNode)
                nodeForEdge.append(tmpNode)
                indexTable[tmpId] = nodeForEdge.count-1
                break
            }

            
        }
        else {
            if let name = attributeDict["ctype"] {
                tmpName = name
            } else if let name = attributeDict["type"] {
                tmpName = name
            }
            if let id = attributeDict["id"] {
                if let c = Int(id) {
                    tmpId = c
                }
            }
            if let id = attributeDict["latency"] {
                if let c = Int(id) {
                    tmpWeight = c
                }
            }
            
            var tmpNodeOpType: nodeOpType!
            if nodeOpTypeArray.contains(where: {
                if ($0 ).name == tmpName {
                    tmpNodeOpType = $0
                    return true
                } else {
                    return false
                }
                
            }) {
                
            } else {
                tmpNodeOpType = nodeOpType(name: tmpName, defaultWeight: tmpWeight)
                nodeOpTypeArray.append(tmpNodeOpType)
            }
            
            tmpNode = Node(name: tmpName, parent: parentGroup, weight: tmpWeight, nodeOpType: tmpNodeOpType, nodeID: tmpId)       // Hol a pontsúly?
            tmpGroup.append(tmpNode)
            nodeForEdge.append(tmpNode)
            indexTable[tmpId] = nodeForEdge.count-1
        }
    }
    
    func parseEdge(attributes attributeDict: [String : String] = [:]) {
        
        var dnodeID: Int!
        var snodeID: Int!
        if let dnode = attributeDict["dnode"] {
            if let c = Int(dnode) {
                dnodeID = c
            }
        }
        if let snode = attributeDict["snode"] {
            if let c = Int(snode) {
                snodeID = c
            }
        }
        if let snode = attributeDict["weight"] {
            if let c = Int(snode) {
                tmpWeight = c
            }
        }
        guard nil != dnodeID else {
            print("Élparserhiba")
            return
        }
        guard nil != snodeID else {
            print("Élparserhiba")
            return
        }
        let indexSNode = indexTable[snodeID]
        let indexDNode = indexTable[dnodeID]
        var tmpEdgeDataType = edgeDataType(name: "Undefined Data Type", defaultWeight: tmpWeight)
        if edgeDataTypeArray.isEmpty {
                    edgeDataTypeArray.append(tmpEdgeDataType)
        }
        let tmpEdge = Edge(name: "Él", weight: tmpWeight, parentNode1: nodeForEdge[indexSNode!], parentNode2: nodeForEdge[indexDNode!], dataType: tmpEdgeDataType)
        nodeForEdge[indexSNode!].children.append(tmpEdge)
        nodeForEdge[indexDNode!].children.append(tmpEdge)
        
    }
    
    // MARK: - XML Parser Delegate
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        switch elementName {
        case "eog":
            var referenceGroup = [GraphElement]()
            for i in 0..<tmpGroup.count {
                referenceGroup.append(tmpGroup[i])
            }
            tmpGraphGroups.append(referenceGroup)
            tmpGroup.removeAll()
            //tmpGraphGroups.append([])
            
            
            
                
                firstEog = false
            
            break
        case "node":
            parseNode(attributes: attributeDict)
            break
        case "edge":
            parseEdge(attributes: attributeDict)
            break
        case "pipe":
            tmpGroup.append(Group(name: "Főcsoport", parent: nil, maxGroupTime: 0))
            //tmpGraphGroups.append([Group(name: "Főcsoport", parent: nil, maxGroupTime: 0)])
            break
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "eog":
            //indexTable.removeAll()
            for i in 0..<tmpGroup.count {
                tmpGraphGroups.last?.last?.children.append(tmpGroup[i])
            }
            tmpGroup.removeAll()
            for i in 0..<(tmpGraphGroups.last?.count)! {
                tmpGroup.append(tmpGraphGroups.last![i])
            }
            if tmpGraphGroups.count == 1 {
                
            } else {
                tmpGraphGroups.removeLast()
            }
            break
        case "node":
            break
        case "pipe":
            break
        default:
            break
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        groups = tmpGraphGroups[0]
        parserCompletionHandler?(groups)
        Log?.Print(log: "## XML Parser: Fájl beolvasva.", detailed: .Normal)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError.localizedDescription)
    }
}
