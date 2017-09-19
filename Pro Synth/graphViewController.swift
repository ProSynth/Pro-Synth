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


    dynamic var groups = [GraphElement]()

    

    
    @IBOutlet var graphAddMenu: NSMenu!
    @IBOutlet weak var addNode: NSMenuItem!
    @IBOutlet weak var addEdge: NSMenuItem!
    @IBOutlet weak var addGroup: NSMenuItem!
    
    var num: Int = 0
    @IBOutlet weak var noGraph: NSTextField!

    
    @IBOutlet var graphTreeController: NSTreeController!
    @IBOutlet weak var graphOutlineView: NSOutlineView!
    


    @IBAction func addGraphMenuButton(_ sender: NSButton) {
    
        let p = NSPoint(x: sender.frame.origin.x, y: sender.frame.origin.y + 90)
        self.graphAddMenu.popUp(positioning: nil, at: p, in: sender.superview)
        
    }
    
    @IBAction func addNode(_ sender: NSMenuItem) {
        
        
        
        groupString.removeAll()
  
        while groupString.count != groups.count {
            groupString.append("")
        }
        
        for i in 0..<groupString.count {
            
            let tmpName:String = groups[i].getName()
            
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
        for i in 0..<groups.count {
            for j in 0..<(groups[i].children.count) {
                nodeString.append(groups[i].children[j].name)
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
            groups.remove(at: indexPath[0])
        case 2:                                 // Pontot akarunk eltávolítani
            groups[indexPath[0]].children.remove(at: indexPath[1])
        case 3:                                 // Élet akarunk eltávolítani
            groups[indexPath[0]].children[indexPath[1]].children.remove(at: indexPath[2])
        default:
            return
        }
        
        // Letiltjuk a gráfelemek hozzáadását, ha már nincsenek megfelelő pntok vagy csoportok
        let appDelegate = NSApplication.shared().delegate as! AppDelegate
        if groups.count == 0 {
            noGraph.isHidden = false
            addNode.isEnabled = false
            addEdge.isEnabled = false
            
            appDelegate.setNodeEnable(enable: false)
            appDelegate.setEdgeEnable(enable: false)
        } else if groups[0].children.count<2 {
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
        newNode?.delegate = self
        newGroup?.delegate = self
        newConnectionManual?.delegate = self
        
     
        addNode.isEnabled = false
        addEdge.isEnabled = false

        graphOutlineView.register(forDraggedTypes: [NSPasteboardTypeString])
    }
    
    func addEdgeWithData(name:String, weight:Int, type:EdgeType, node1:Node, node2:Node) {
        let tmpEdge = Edge(name: name, weight: weight)
        node1.children.append(tmpEdge as GraphElement)
        node2.children.append(tmpEdge as GraphElement)
    }
    
    func addNodeWithData(name:String, weight:Int, type:NodeType, group:Group)  {
        
        group.children.append(Node(name: name, weight: weight) as GraphElement)
        
        addEdge.isEnabled = true
        let appDelegate = NSApplication.shared().delegate as! AppDelegate
        appDelegate.setEdgeEnable(enable: true)
        return
    }
    
    func addGroupWithData(name: String)  {
        groups.append(Group(name: name) as GraphElement)
        
        if groups.count > 0 {
            addNode.isEnabled = true
            addNodeMenuEnabled = true
            
            let appDelegate = NSApplication.shared().delegate as! AppDelegate
            appDelegate.setNodeEnable(enable: true)
            
            noGraph.isHidden = true
        }

    }
    

    func importMethod() {
        do {

            let data = try NSString(contentsOfFile: (importGraphPath?.path)!,
                                    encoding: String.Encoding.utf8.rawValue)
            
            var abc  = [String] ()
            abc = data.components(separatedBy: "\n")
            for i in 0..<abc.count {
                print(i,". a sorban. Adat:",abc[i])
            }
            
            if abc[0].range(of: "digraph") != nil {
                print("Ez egy gráf lesz")
                addGroupWithData(name: "A gráf")
                for element in 1..<abc.count {
                    if (abc[element].range(of: "->") != nil) && (abc[element].range(of: "label") != nil) {
                        print("Ez egy él")
                        var edgeArray = abc[element].components(separatedBy: " ")
                        let node1 = Int(edgeArray[0])
                        let node2 = Int(edgeArray[2])
                        var name = edgeArray[4].components(separatedBy: "\"")
                        addEdgeWithData(name: name[1], weight: 0, type: .none, node1: groups[0].children[node1!] as! Node, node2: groups[0].children[node2!] as! Node)
                    } else if (abc[element].range(of: "label") != nil) {
                        print("Ez egy pont")
                        if let match = abc[element].range(of: "(?<=\")[^:]+", options: .regularExpression) {
                            addNodeWithData(name: abc[element].substring(with: match), weight: 5, type: .none, group: groups[0] as! Group)
                        }
                        
                    }
                }
            }
            
            print("Fájl vége")
        } catch {
            print("Hiba van")
        }
    }
    
    
    @IBAction func but(_ sender: Any) {
        
        globalDelegate?.loadAttributes(name: groups[0].children[0].name, weight: 42, nodeID: 0, opType: .none, group: groups[0])
    }

}














// Extensions!!!!

extension graphViewController: newNodeDelegate {
    func createNodeFromData(name: String, weight:Int, type:NodeType, groupIndex:Int) {
        
        addNodeWithData(name: name, weight: weight, type: type, group: groups[groupIndex] as! Group)
    }
}

extension graphViewController: newGroupDelegate {
    func createGroupFromData(name: String) {
        
        addGroupWithData(name: name)
        
    }
}

extension graphViewController: newConnectionDelegate {
    func createConnectionFromData(name: String, weight:Int, type:EdgeType, node1Index:IndexPath, node2Index: IndexPath) {
        
        addEdgeWithData(name: name, weight: weight, type: type, node1: groups[node1Index[0]].children[node1Index[1]] as! Node, node2: groups[node2Index[0]].children[node2Index[1]] as! Node)
        
    }
}

//////////////////////////////////////////////////////////////////////////////////////
//!         Graphimport
//!===================================================================================
//!         Leírás: Itt lesz a gráf importálás szekció
//!
//!
//////////////////////////////////////////////////////////////////////////////////////


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
        
        //let selectedItem = graphOutlineView.item(atRow: graphOutlineView.selectedRow) as? GraphElement
        //print(selectedItem?.name as Any)
        
    }
}


