//
//  groupGlobalAttributeViewController.swift
//  Pro Synth
//
//  Created by Gergo Markovits on 2017. 09. 23..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

class groupGlobalAttributeViewController: NSViewController {

    @IBOutlet weak var name: NSTextField!
    @IBOutlet weak var groupID: NSTextField!
    @IBOutlet weak var maxTime: NSTextField!
    @IBOutlet weak var nodesOfGroupTableView: NSTableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        NotificationCenter.default.addObserver(self, selector: #selector(self.update), name: Notification.Name("groupAttribute"), object: nil)
        update()
    }
    
    func update() {
        name.stringValue = (groupAttribute as GraphElement).name
        name.stringValue = groupAttributesP1.name
        groupID.stringValue = String(groupAttributesP1.groupID)
        maxTime.integerValue = groupAttributesP1.maxTime
        nodesOfGroupTableView.reloadData()
    }
    
}


extension groupGlobalAttributeViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return (groupAttribute as GraphElement).children.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if tableColumn == tableView.tableColumns[0] {
            return (groupAttribute as GraphElement).children[row].name
        } else if tableColumn == tableView.tableColumns[1] {
            return String((groupAttribute as GraphElement).children[row].children.count)
        } else {
            return nil
        }
    }
}
