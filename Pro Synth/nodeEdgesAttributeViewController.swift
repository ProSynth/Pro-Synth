//
//  nodeSinthesisAttributeViewController.swift
//  Pro Synth
//
//  Created by Gergo Markovits on 2017. 09. 23..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

class nodeEdgesAttributeViewController: NSViewController {

    
    
    @IBOutlet weak var nodeEdgesTableView: NSTableView!
    @IBOutlet weak var sumOfEdgesWeights: NSTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        NotificationCenter.default.addObserver(self, selector: #selector(self.update), name: Notification.Name("nodeAttribute"), object: nil)
        update()
    }
    
    func update() {
        nodeEdgesTableView.reloadData()
        var sum: Int = 0
        for i in 0..<tmpNodeAttribute.children.count {
            sum += (tmpNodeAttribute.children[i] as! Edge).weight
        }
        sumOfEdgesWeights.integerValue = sum
    }
    
}

extension nodeEdgesAttributeViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return  (tmpNodeAttribute as GraphElement).children.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if tableColumn == tableView.tableColumns[0] {
            return (tmpNodeAttribute as GraphElement).children[row].name
        } else if tableColumn == tableView.tableColumns[1] {
            let edge = (tmpNodeAttribute as GraphElement).children[row]
            let edgeAsEdge = edge as! Edge
            return edgeAsEdge.weight
        } else {
            return nil
        }
    }
    
}
