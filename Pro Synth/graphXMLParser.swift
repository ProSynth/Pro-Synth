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
                tmpLocalGroup = Group(name: tmpName, parent: nil, maxGroupTime: 0)
                tmpGroup.append(tmpLocalGroup)
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
                tmpLocalGroup = Group(name: "Group", parent: nil, maxGroupTime: 0, groupID: tmpId, loop: lType)
                tmpGroup.append(tmpLocalGroup)
                break
            default:
                if let name = attributeDict["ctype"] {
                    tmpName = name
                }
                if let id = attributeDict["id"] {
                    if let c = Int(id) {
                        tmpId = c
                    }
                }
                tmpNode = Node(name: tmpName, parent: nil, weight: 1, nodeOpType: nil, nodeID: tmpId)       // Hol a pontsúly?
                tmpGroup.append(tmpNode)
                break
            }

            
        }
        else {
            if let name = attributeDict["ctype"] {
                tmpName = name
            }
            if let id = attributeDict["id"] {
                if let c = Int(id) {
                    tmpId = c
                }
            }
            tmpNode = Node(name: tmpName, parent: nil, weight: 1, nodeOpType: nil, nodeID: tmpId)       // Hol a pontsúly?
            tmpGroup.append(tmpNode)
        }
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
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError.localizedDescription)
    }
}
