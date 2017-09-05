//
//  ViewController.swift
//  Pro Synth
//
//  Created by Gergo Markovits on 2017. 08. 17..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {
    /*
    lazy var newNodeViewController: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: "newNode")
            as! NSViewController
    }()
    
    lazy var newGroupViewController: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: "newGroup")
            as! NSViewController
    }()
    
    /* Pontok hozzáadása, elvétele függvények */
    
    public func newNode() {
        print("newNode lesz a tree-ben")
        /*if let rootItem = graphOutlineView.item(atRow: 0) {
            graphOutlineView.insertItems(at: NSIndexSet(index:0) as IndexSet, inParent: rootItem, withAnimation: [.slideLeft])
        }*/
        self.presentViewControllerAsSheet(newNodeViewController)
    }
    
    func newGroup() {
        print("Új csoport lesz a tree-ben")
        self.presentViewControllerAsSheet(newGroupViewController)
    }
    
    func newConnection() {
        print("Új vezeték létrehozása")
    }
    @IBAction func deleteAny(_ sender: NSButton) {
        print("Töröljünk egy valamit (a kijelöltet)")
    }
   
    @IBOutlet var graphTreeController: NSTreeController!
    @IBOutlet weak var graphOutlineView: NSOutlineView!
    @IBOutlet weak var horLine: NSBox!
    
    @IBOutlet weak var graphMenuAddButton: NSButton!
    @IBOutlet weak var totalConnections: NSTextField!
    @IBOutlet weak var totalNodes: NSTextField!

    
    /* Deklaráljuk a az egyes popup menüpontokat */
    
    let graphAddMenu = NSMenu()
    
    let addNode = NSMenuItem(title: "Add Node", action: #selector(newNode), keyEquivalent: "")
    let addGroup = NSMenuItem(title: "Add Group", action: #selector(newGroup), keyEquivalent: "")
    let addWire = NSMenuItem(title: "Add Connection", action: #selector(newConnection), keyEquivalent: "")
    
    
    /* Balgombnyomásra feljön a menü */
    @IBAction func graphMenuAddButton(_ sender: NSButton) {
        let p = NSPoint(x: sender.frame.origin.x, y: sender.frame.origin.y + 95)
        self.graphAddMenu.popUp(positioning: self.graphAddMenu.item(at: 0), at: p, in: sender.superview)
    }

    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        
        // Set up menu Összeállítjuk a graphaddmenü kinézetét
        self.graphAddMenu.addItem(self.addNode)
        self.graphAddMenu.addItem(self.addWire)
        self.graphAddMenu.addItem(NSMenuItem.separator())
        self.graphAddMenu.addItem(self.addGroup)


        // Do any additional setup after loading the view.
        addData()
        graphOutlineView.expandItem(nil, expandChildren: true)
        graphOutlineView.register(forDraggedTypes: [NSPasteboardTypeString])*/
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    /*
    func addData() {
        let root = [
            "name": "GRAPH NODES",
            "isLeaf": false
        ] as [String : Any]
        
        let dict: NSMutableDictionary = NSMutableDictionary(dictionary: root)
        let p1 = graphlist()
        p1.name = "Első pont"
        let p2 = graphlist()
        p2.name = "Második pont"
        
        dict.setObject([p1, p2], forKey: "children" as NSCopying)
        graphTreeController.addObject(dict)
        
        let root2 = [
            "name": "GRAPH NODES 2",
            "isLeaf": false
            ] as [String : Any]
        
        let dict2: NSMutableDictionary = NSMutableDictionary(dictionary: root2)
        let p3 = graphlist()
        p3.name = "Harmadik pont"
        let p4 = graphlist()
        p4.name = "Negyedik pont"
        
        dict2.setObject([p3, p4], forKey: "children" as NSCopying)
        graphTreeController.addObject(dict2)
    }
    
    //MARK: - Hellpers
    
    func isHeader(item: Any) -> Bool {
        if let item = item as? NSTreeNode {
            return !(item.representedObject is graphlist)
        } else {
            return !(item is graphlist)
        }
    }
    //MARK: - Delegete Method
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if isHeader(item: item) {
            return outlineView.make(withIdentifier: "HeaderCell", owner: self)
        } else {
            return outlineView.make(withIdentifier: "DataCell", owner: self)
        }
    }
    
    //MARK: - DataSource
    
    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        let pbItem = NSPasteboardItem()             //Elmozdíthatóvá tesszük az Item-et
        
        if let graphlist = ((item as? NSTreeNode)?.representedObject) as? graphlist {
            pbItem.setString(graphlist.name, forType: NSPasteboardTypeString)
            return pbItem                           //De csak azt, ami a levélben van ( az alsóbb szinten)
        }
        
        return nil
    }
    
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        let canDrag = index >= 0 && item != nil
        
        if canDrag {
            return NSDragOperation.move
        } else {
            return NSDragOperation.init(rawValue: 0)
        }
        
    }                                               //Az elmozdításhoz hozzátesszük a cellák közötti jelölést, hogy hová akarjuk tenni
    
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        let pb = info.draggingPasteboard()
        let name = pb.string(forType: NSPasteboardTypeString)
        
        var sourceNode: NSTreeNode?
        
        if let item = item as? NSTreeNode, item.children != nil {
            for node in item.children! {
                if let graphlist = node.representedObject as? graphlist {
                    if graphlist.name == name {
                        sourceNode = node
                    }
                }
            }
        }
        
        if sourceNode == nil {
            return false
        }
        // Itt az array-ben az első a root száma, a második a helye azon belül
        let indexArr: [Int] = [0, index]
        let toIndexPath = NSIndexPath(indexes: indexArr, length: 2)
        graphTreeController.move(sourceNode!, to: toIndexPath as IndexPath)
        
        return true
    }
    
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return isHeader(item:true)
    }
*/
}

