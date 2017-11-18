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
        if let type = attributeDict["loop"] {
            var lType: LoopType
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
            let tmpLocaalGroup = Group(name: "Group", parent: nil, maxGroupTime: 0, groupID: tmpId, loop: lType)
            tmpGroup.append(tmpLocaalGroup)
        } else {
            if let name = attributeDict["ctype"] {
                tmpName = name
            }
            if let id = attributeDict["id"] {
                if let c = Int(id) {
                    tmpId = c
                }
            }
            tmpNode = Node(name: tmpName, parent: nil, weight: 1, nodeOpType: nil, nodeID: tmpId)
            tmpGroup.append(tmpNode)
        }
    }
    
    // MARK: - XML Parser Delegate
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        switch elementName {
        case "eog":
            tmpGroup.removeAll()
            break
        case "node":
            
            break
        case "edge":
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
            <#code#>
            break
        case "node":
            break
        default:
            break
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        parserCompletionHandler?(groups)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError.localizedDescription)
    }
}
