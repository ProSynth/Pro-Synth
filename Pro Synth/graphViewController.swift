//
//  graphViewController.swift
//  Pro Synth
//
//  Created by Gergo Markovits on 2017. 08. 26..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa



var groupString = [String] ()
var nodeString = [String] ()
var nodePath = [IndexPath] ()
var addNodeMenuEnabled : Bool = false
var addEdgeMenuEnabled : Bool = false
var index: Int = 0

var importGraphPath : URL?

var defaultGroupId: Int = -1

protocol globalAttributeDelegate {
    func loadAttributes(name: String, weight: Int, nodeID: Int, opType: NodeType, group: GraphElement)
}

class graphViewController: NSViewController {
    
    var globalDelegate:globalAttributeDelegate?
    
    var url : NSURL = NSURL(string:"")!
    

    
    lazy var newNode : newNode? = {
        return self.storyboard!.instantiateController(withIdentifier: "newNode")
            as! NSViewController
    } () as! newNode
    
    
    
    lazy var newGroup : newGroup? = {
        return self.storyboard!.instantiateController(withIdentifier: "newGroup")
            as! NSViewController
    } () as! newGroup
    
    lazy var newConnectionManual : newConnectionManual? = {
        return self.storyboard!.instantiateController(withIdentifier: "newConnectionManual")
            as! NSViewController
    } () as! newConnectionManual

    dynamic var selectedGroups = [GraphElement]()
    var allGroups = [[GraphElement]]()
    

    
    @IBOutlet var graphAddMenu: NSMenu!
    @IBOutlet weak var addNode: NSMenuItem!
    @IBOutlet weak var addEdge: NSMenuItem!
    @IBOutlet weak var addGroup: NSMenuItem!
    
    var num: Int = 0
    @IBOutlet weak var noGraph: NSTextField!

    
    @IBOutlet var graphTreeController: NSTreeController!
    @IBOutlet weak var graphOutlineView: NSOutlineView!
    @IBOutlet weak var graphScrollView: NSScrollView!
    @IBOutlet weak var selectGraph: NSPopUpButton!
    
    @IBOutlet weak var sideBarWidth: NSLayoutConstraint!
    

    @IBAction func addGraphMenuButton(_ sender: NSButton) {
    
        let p = NSPoint(x: sender.frame.origin.x, y: sender.frame.origin.y + 90)
        self.graphAddMenu.popUp(positioning: nil, at: p, in: sender.superview)
        
    }
    
    @IBAction func addNode(_ sender: NSMenuItem) {
        
        
        
        groupString.removeAll()
  
        while groupString.count != selectedGroups.count {
            groupString.append("")
        }
        
        for i in 0..<groupString.count {
            
            let tmpName:String = selectedGroups[i].getName()
            
            groupString[i] = tmpName
        }
        
        if graphOutlineView.numberOfSelectedRows == 0 {
            defaultGroupId = 0
        } else {
            let indexPath: IndexPath = (graphOutlineView.item(atRow: graphOutlineView.selectedRow) as! NSTreeNode).indexPath
            defaultGroupId = indexPath[0]
        }
        

        
        
        self.presentViewControllerAsSheet(newNode!)
        
    }
    @IBAction func addGroup(_ sender: NSMenuItem) {
        

        
        self.presentViewControllerAsSheet(newGroup!)
    }
    
    public func launchNewGroupSheet(notification: NSNotification) {
        self.presentViewControllerAsSheet(newGroup!)
    }
    
    func newGroupMenu(){
        self.presentViewControllerAsSheet(newGroup!)
    }
    
    @IBAction func addEdge(_ sender: NSMenuItem) {
        nodeString.removeAll()
        nodePath.removeAll()
        for i in 0..<selectedGroups.count {
            for j in 0..<(selectedGroups[i].children.count) {
                nodeString.append(selectedGroups[i].children[j].name)
                nodePath.append(IndexPath(indexes: [i,j]))
                
            }
        }
        
        self.presentViewControllerAsSheet(newConnectionManual!)
    }
    
    @IBAction func removeGraphElement(_ sender: NSButton) {
        //print(graphTreeController.)
        //print(graphOutlineView.selecte)
        let indexPath: IndexPath = (graphOutlineView.item(atRow: graphOutlineView.selectedRow) as! NSTreeNode).indexPath
        
        switch indexPath.count {
        case 1:                                 // Csoportot akarunk eltávolítani
            selectedGroups.remove(at: indexPath[0])
        case 2:                                 // Pontot akarunk eltávolítani
            selectedGroups[indexPath[0]].children.remove(at: indexPath[1])
        case 3:                                 // Élet akarunk eltávolítani
            selectedGroups[indexPath[0]].children[indexPath[1]].children.remove(at: indexPath[2])
        default:
            return
        }
        
        // Letiltjuk a gráfelemek hozzáadását, ha már nincsenek megfelelő pntok vagy csoportok
        let appDelegate = NSApplication.shared().delegate as! AppDelegate
        if selectedGroups.count == 0 {
            noGraph.isHidden = false
            addNode.isEnabled = false
            addEdge.isEnabled = false
            
            appDelegate.setNodeEnable(enable: false)
            appDelegate.setEdgeEnable(enable: false)
        } else if selectedGroups[0].children.count<2 {
            addEdge.isEnabled = false
            
            appDelegate.setEdgeEnable(enable: false)
        }
        
        
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.launchNewGroupSheet(notification:)), name: Notification.Name("hotKeyGroup"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.addNode(_:)), name: Notification.Name("hotKeyNode"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.addEdge(_:)), name: Notification.Name("hotKeyEdge"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.importMethod), name: Notification.Name("importGraphMethod"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.doSynth), name: Notification.Name("startSynth"), object: nil)

        newNode?.delegate = self
        newGroup?.delegate = self
        newConnectionManual?.delegate = self
        
     
        addNode.isEnabled = false
        addEdge.isEnabled = false

        
        selectGraph.removeAllItems()
        selectGraph.addItem(withTitle: "Untitled Graph")
        graphOutlineView.register(forDraggedTypes: [NSPasteboardTypeString])
    }
    
    func addEdgeWithData(name:String, weight:Int, type:EdgeType, snode:Node, dnode:Node) {
        let tmpEdge = Edge(name: name, weight: weight, parentNode1:snode, parentNode2:dnode)
        snode.children.append(tmpEdge as GraphElement)
        dnode.children.append(tmpEdge as GraphElement)
    }
    
    func addNodeWithData(name:String, weight:Int, type:NodeType, group:Group, nodeOpType:nodeOpType, nodeID: Int = -1)  {
        
        group.children.append(Node(name: name, weight: weight, nodeOpType: nodeOpType, nodeID: nodeID) as GraphElement)
        
        addEdge.isEnabled = true
        let appDelegate = NSApplication.shared().delegate as! AppDelegate
        appDelegate.setEdgeEnable(enable: true)
        return
    }
    
    func addGroupWithData(name: String, maxGroupTime: Int, groupID: Int = -1)  {
        selectedGroups.append(Group(name: name, maxGroupTime: maxGroupTime, groupID: groupID) as GraphElement)
        
        if selectedGroups.count > 0 {
            addNode.isEnabled = true
            addNodeMenuEnabled = true
            
            let appDelegate = NSApplication.shared().delegate as! AppDelegate
            appDelegate.setNodeEnable(enable: true)
            
            noGraph.isHidden = true
        }

    }
    
    //////////////////////////////////////////////////////////////////////////////////////
    //!         Graphimport
    //!===================================================================================
    //!         Leírás: Itt lesz a gráf importálás szekció
    //!
    //!
    //////////////////////////////////////////////////////////////////////////////////////
    
    func importMethod() {
        
        var sumEl: Int = 0
        var output = [Int : Bool]()
        var input = [Int : Bool]()
        
        let numberOfGroups = selectedGroups.count
        let numberOfNodes = Node.currentNodeID
        
        do {
            // Adat beolvasása a data stringbe
            let data = try NSString(contentsOfFile: (importGraphPath?.path)!,
                                    encoding: String.Encoding.utf8.rawValue)
            // Az adat szétszedése enterenként egy string tömbbe
            var dataRow  = [String] ()
            dataRow = data.components(separatedBy: "\n")
            
            var nodeGroupDictionary = [Int:Int]()
            
            if dataRow[0].range(of: "digraph") != nil {                                             //Ha az első sorban benne van a digraph szöveg, akkor ez egy graphviz formátum
                for element in 1..<dataRow.count {                                                  //Végigmegyünk az összes soron, keresve a gráfcsoportokat
                    let stringArray = dataRow[element].components(separatedBy: " ")
                    if (stringArray[0] == "Subgraph") || (stringArray[0] == "subgraph") {           //Ha tartalmazza a Subgraph vagy subgraph stringet, akkor ez egy szubgráf definíció

                        var groupID : Int                                           //Leszedjük belőle a csoportID-t
                        var groupName : String = "Csoport1"                                         //Csoport1 lesz a default csoportnév
                        var groupMax : Int                                                       //Csoport időkorlát
                        let attributes = dataRow[element].range(of: "(?<={)[^}]+", options: .regularExpression) //Megnézzük mi van a kapcsos zárójelen belül
                        let prop = dataRow[element].components(separatedBy: " ")
                        //print(dataRow[element])
                        groupName = prop[1]
                        
                        if let propArray = prop[2].range(of: "(?<=\")[^:]+", options: .regularExpression) {
                            groupID = Int(prop[2].substring(with: propArray))!
                        } else {
                            groupID = -2
                        }
                        if let propArray2 = prop[2].range(of: "(?<=:)[^\"]+", options: .regularExpression) {
                            groupMax = Int(prop[2].substring(with: propArray2))!
                        } else {
                            groupMax = 0
                        }
                        addGroupWithData(name: groupName, maxGroupTime: groupMax, groupID: groupID)            //Hozzáadjuk a csoportot
                        /*
                        for i in 0..<prop.count {
                            if prop[i].range(of: "label") != nil {                                  //Ha van benne label, akkor abban a stringben lesznek az attribútumok
                                
                                
                            }
                            
                        }*/
                       
                    }
                    
                }
                
                for element in 1..<(dataRow.count-3) {
                    var nodeName : String
                    var nodeWeight : Int
                    var nodeGroupID : Int
                    
                    var edgeNode1ID : Int
                    var edgeNode2ID : Int
                    var edgeName : String
                    var edgeWeight : Int
                    
                    
                    let stringArray = dataRow[element].components(separatedBy: " ")
                    if stringArray[1].range(of: "label") != nil {
                        if let propArray = dataRow[element].range(of: "(?<=\")[^\"]+", options: .regularExpression) {
                            let groupMax = dataRow[element].substring(with: propArray)
                            let propArray2 = groupMax.components(separatedBy: ":")
                            let name = Array(propArray2[0].characters)
                            if  name[0] == "@"{
                                nodeName = propArray2[1]
                            } else {
                                nodeName = propArray2[0]
                            }
                            nodeWeight = Int(propArray2[5])!
                            nodeGroupID = Int(propArray2[6])!+numberOfGroups
                            let tmpnodeID = Int(stringArray[0])!+numberOfNodes
                            
                            nodeGroupDictionary[tmpnodeID] = nodeGroupID
                            //let index = groups.index(of: )
                            let index = selectedGroups.index(where: { ($0 as! Group).groupID == nodeGroupID})!
                            
                            for i in 0..<nodeOpTypeArray.count {
                                if (nodeOpTypeArray[i].name == propArray2[1]) {
                                    break
                                }
                            }
                            if nodeOpTypeArray.contains(where: {($0 ).name == propArray2[1] }) {
                                
                            } else {
                                nodeOpTypeArray.append(nodeOpType(name: propArray2[1], defaultWeight: nodeWeight))
                            }
                            output[tmpnodeID] = true
                            input[tmpnodeID] = true
                            addNodeWithData(name: nodeName, weight: nodeWeight, type: .none, group: selectedGroups[index] as! Group, nodeOpType: nodeOpType(name:propArray2[1] ,defaultWeight:nodeWeight), nodeID: tmpnodeID)
                        }
                    } else if stringArray[1] == "->" {
                        edgeNode1ID = Int(stringArray[0])!
                        edgeNode2ID = Int(stringArray[2])!
                        if let propArray = dataRow[element].range(of: "(?<=\")[^\"]+", options: .regularExpression) {
                            let groupMax = dataRow[element].substring(with: propArray)
                            let propArray2 = groupMax.components(separatedBy: ":")
                            let name = Array(propArray2[0].characters)
                            if  name[0] != "@"{
                                edgeName = propArray2[0]
                            } else {
                                edgeName = "Él"
                            }
                            
                            edgeWeight = Int(propArray2[1])!
                            
                            
                            
                            var index1N: Int = -1
                            var index1G: Int = -1
                            var index2N: Int = -1
                            var index2G: Int = -1
                            
                            for i in 0..<selectedGroups.count {
                                for k in 0..<selectedGroups[i].children.count {
                                    if (selectedGroups[i].children[k] as! Node).nodeID == edgeNode1ID {
                                        index1N = k
                                        index1G = i
                                        
                                    }
                                    
                                    if (selectedGroups[i].children[k] as! Node).nodeID == edgeNode2ID {
                                        index2N = k
                                        index2G = i
                                        
                                    }
                                }
                            }
                            
                            /* Éltípus hozzáadása */
                            
                            for i in 0..<edgeDataTypeArray.count {
                                if (edgeDataTypeArray[i].name == propArray2[2]) {
                                    break
                                }
                            }
                            if edgeDataTypeArray.contains(where: {($0 ).name == propArray2[2] }) {
                                
                            } else {
                                edgeDataTypeArray.append(edgeDataType(name: propArray2[2], defaultWeight: edgeWeight))
                            }
                            
                            let defaultString : String = "\(selectedGroups[index1G].children[index1N].name) - \(selectedGroups[index2G].children[index2N].name) él"
                            
                            if edgeWeight == 0 {
                                print("Hiba van a forrás fájlban")
                            }
                            output[edgeNode1ID] = false
                            input[edgeNode2ID] = false
                            //Itt még a groups 0-t javítani kell
                            addEdgeWithData(name: defaultString, weight: edgeWeight, type: .none,
                                            snode: selectedGroups[index1G].children[index1N] as! Node,
                                            dnode: selectedGroups[index2G].children[index2N] as! Node)
                            sumEl += edgeWeight
                        }
                    }
                    
                }
            }
            
            for i in 0..<selectedGroups.count {
                for j in 0..<selectedGroups[i].children.count {
                    if output[(selectedGroups[i].children[j] as! Node).nodeID]! {
                        (selectedGroups[i].children[j] as! Node).type = .Output
                    } else if input[(selectedGroups[i].children[j] as! Node).nodeID]! {
                        (selectedGroups[i].children[j] as! Node).type = .Input
                    } else {
                        (selectedGroups[i].children[j] as! Node).type = .Normal
                    }
                }
            }
            
            for (key, value) in output {
                if value == true {
                    
                }
            }
            
            print("Fájl vége")
            print(sumEl)
        } catch {
            print("Hiba van")
        }
    }
    
    
    @IBAction func but(_ sender: Any) {
        
        NotificationCenter.default.post(name: Notification.Name("nodeAttribute"), object: self)
    }
    
    
    @IBAction func selectOtherGroups(_ sender: Any) {
        if allGroups.count > 0 {
           selectedGroups = allGroups[selectGraph.indexOfSelectedItem]
        }
        
    }
    
    
    func doSynth()  {

        // Dekompozíció cégrehajtása
        let WNCutDecomposerTool: WNCutDecomposer = WNCutDecomposer()
        let grouping = WNCutDecomposerTool.DoProcess(sourceGroups: selectedGroups, p:0.001)
        guard nil != grouping  else {
            print("A Dekompozíció nem végződött el")
            return
        }
        
        allGroups.append(selectedGroups)
        //groups.removeAll()
        //groups = grouping!
        allGroups.append(grouping!)
        selectGraph.addItem(withTitle: "Decomposition")
        selectGraph.selectItem(withTitle: "Decomposition")
        selectedGroups = allGroups[1]
        
        var we: Int = 0
        for group in 0..<selectedGroups.count {
            for node in 0..<selectedGroups[group].children.count {
                we += (selectedGroups[group].children[node] as! Node).weight
            }
        }
        print("Összes pont: \(we)")
        
    }

}














// Extensions!!!!

extension graphViewController: newNodeDelegate {
    func createNodeFromData(name: String, weight:Int, type:NodeType, groupIndex:Int, nodeOpType:nodeOpType) {
        
        addNodeWithData(name: name, weight: weight, type: type, group: selectedGroups[groupIndex] as! Group, nodeOpType: nodeOpType)
    }
}

extension graphViewController: newGroupDelegate {
    func createGroupFromData(name: String) {
        
        addGroupWithData(name: name, maxGroupTime: 0)
        //TODO
    }
}

extension graphViewController: newConnectionDelegate {
    func createConnectionFromData(name: String, weight:Int, type:EdgeType, node1Index:IndexPath, node2Index: IndexPath) {
        
        addEdgeWithData(name: name, weight: weight, type: type, snode: selectedGroups[node1Index[0]].children[node1Index[1]] as! Node, dnode: selectedGroups[node2Index[0]].children[node2Index[1]] as! Node)
        
    }
}




extension graphViewController: NSOutlineViewDataSource {
    
}

extension graphViewController: NSOutlineViewDelegate {
    
//////////////////////////////////////////////////////////////////////////////////////
//!         Delegate functions implementations
//////////////////////////////////////////////////////////////////////////////////////
//!         outlineView() -> NSPasteboardItem
//!===================================================================================
//!         Leírás: Ez a függvény teszi lehetővé, hogy az egyes gráfelemek elhúzhatók
//!                 legyenek a helyükről. Ilyenkor létrehozunk egy PasteboardItemet
//!                 ami a drag-ért felelős
//////////////////////////////////////////////////////////////////////////////////////
    
    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        let pbItem = NSPasteboardItem()
        
        if let graphList = ((item as? NSTreeNode)?.representedObject) as? GraphElement {
            pbItem.setString(graphList.name, forType: NSPasteboardTypeString)
            return pbItem
        }
        
        return nil
    }

//////////////////////////////////////////////////////////////////////////////////////
//!         outlineView() -> NSDragOperation helykijelölő
//!===================================================================================
//!         Leírás: Ez a delegation függvény segítségével láthatjuk, hogy mely helyekre
//!                 lehet az adott objektumot beilleszteni
//////////////////////////////////////////////////////////////////////////////////////
    
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {

        return .move
    }
    
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        let pb = info.draggingPasteboard()
        let name = pb.string(forType: NSPasteboardTypeString)
        
        var sourceNode: NSTreeNode?
        
        if let item = item as? NSTreeNode, item.children != nil {
            for node in item.children! {
                if let graphList = node.representedObject as? GraphElement {
                    if graphList.name == name {
                        sourceNode = node
                    }
                }
            }
        }
        if sourceNode == nil {
            return false
        }
        //info.animatesToDestination = true
        let indexArr: [Int] = [0, index]
        let toIndexPath = NSIndexPath(indexes: indexArr, length: 2)
        graphTreeController.move(sourceNode!, to: toIndexPath as IndexPath)
        
        return true
    }

//////////////////////////////////////////////////////////////////////////////////////
//!         outlineView() -> NSView Cellalétrehozó
//!===================================================================================
//!         Leírás: Itt hozzuk létre az egyes gráfelemek kinézetét, és itt kerül be-
//!                 állításra, hogy úgy nézzek ki minden típusú cella, ahogyan kell.
//!                 Az egyes cellák típusa a subclassok típusától függ, amelyeknek
//!                 egy ősük van, ezért az is operátorral komparálhatók
//////////////////////////////////////////////////////////////////////////////////////
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        let type = (item as? NSTreeNode)?.representedObject
        
        if  type is Node{
            return outlineView.make(withIdentifier: "DataCell", owner: self)
        } else if type is Group {
            return outlineView.make(withIdentifier: "HeaderCell", owner: self)
        } else if type is Edge {
            return outlineView.make(withIdentifier: "EdgeCell", owner: self)
        } else {
            return nil
        }
    }
    
//////////////////////////////////////////////////////////////////////////////////////
//!         outlineViewSelectionDidChange()
//!===================================================================================
//!         Leírás: Ez a delegation függvény akkor fut le, hogy ha a gráflistában
//!                 új elemre kattintottunk.
//////////////////////////////////////////////////////////////////////////////////////
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        //print((graphOutlineView.item(atRow: graphOutlineView.selectedRow) as! NSTreeNode).indexPath)
        var path:IndexPath = (graphOutlineView.item(atRow: graphOutlineView.selectedRow) as! NSTreeNode).indexPath
        switch path.count {
        case 1:
            groupAttributesP1.name = selectedGroups[path[0]].name
            groupAttributesP1.groupID = (selectedGroups[path[0]] as! Group).groupID
            groupAttributesP1.maxTime = (selectedGroups[path[0]] as! Group).maxTime
            
            groupAttribute = selectedGroups[path[0]] as! Group
            
            NotificationCenter.default.post(name: Notification.Name("groupAttribute"), object: self)
        case 2:
            nodeAttributesPl.name = selectedGroups[path[0]].children[path[1]].name
            nodeAttributesPl.weight = (selectedGroups[path[0]].children[path[1]] as! Node).weight
            nodeAttributesPl.nodeID = (selectedGroups[path[0]].children[path[1]] as! Node).nodeID
            nodeAttributesPl.groupID = (selectedGroups[path[0]] as! Group).groupID
            nodeAttributesPl.numberOfEdge = (selectedGroups[path[0]].children[path[1]] as! Node).numberOfConnectedEdge
            //nodeAttributesPl.opType = (groups[path[0]].children[path[1]] as! Node).opType!
            
            nodeAttribute = selectedGroups[path[0]].children[path[1]] as! Node
            
            NotificationCenter.default.post(name: Notification.Name("nodeAttribute"), object: self)
        case 3:
            edgeAttributesP1.name = selectedGroups[path[0]].children[path[1]].children[path[2]].name
            edgeAttributesP1.edgeID = (selectedGroups[path[0]].children[path[1]].children[path[2]] as! Edge).edgeID
            edgeAttributesP1.weight = (selectedGroups[path[0]].children[path[1]].children[path[2]] as! Edge).weight
            NotificationCenter.default.post(name: Notification.Name("edgeAttribute"), object: self)
        default:
            print("Hiba az attribútumszerkesztőben")
        }
        
        //let selectedItem = graphOutlineView.item(atRow: graphOutlineView.selectedRow) as? GraphElement
        //print(selectedItem?.name as Any)
        
       
    }
}


