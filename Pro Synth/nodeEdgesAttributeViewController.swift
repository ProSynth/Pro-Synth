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
    @IBOutlet weak var sumOfEdgesSource: NSTextField!
    @IBOutlet weak var sumOfEdgesDestination: NSTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        NotificationCenter.default.addObserver(self, selector: #selector(self.update), name: Notification.Name("nodeAttribute"), object: nil)
        update()
    }
    
    func update() {
        nodeEdgesTableView.reloadData()
        var sum: Int = 0
        var sumS: Int = 0
        var sumD: Int = 0
        for i in 0..<tmpNodeAttribute.children.count {
            if (tmpNodeAttribute.children[i] as! Edge).parentsNode == tmpNodeAttribute {
                sumS += (tmpNodeAttribute.children[i] as! Edge).weight
            } else {
                sumD += (tmpNodeAttribute.children[i] as! Edge).weight
            }
            sum += (tmpNodeAttribute.children[i] as! Edge).weight
        }
        sumOfEdgesWeights.integerValue = sum
        sumOfEdgesSource.integerValue = sumS
        sumOfEdgesDestination.integerValue = sumD
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
