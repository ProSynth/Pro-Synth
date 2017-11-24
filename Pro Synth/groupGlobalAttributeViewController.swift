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
    @IBOutlet weak var groupType: NSTextField!
    @IBOutlet weak var loopCount: NSTextField!
    @IBOutlet weak var loopCountText: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        NotificationCenter.default.addObserver(self, selector: #selector(self.update), name: Notification.Name("groupAttribute"), object: nil)
        update()
    }
    
    func update() {
        name.stringValue = tmpGroupAttribute.name
        groupID.stringValue = String(tmpGroupAttribute.groupID)
        maxTime.integerValue = tmpGroupAttribute.maxTime
        switch tmpGroupAttribute.loop {
        case .None:
            groupType.stringValue = "Group"
            loopCount.isHidden = true
            loopCountText.isHidden = true
            break
        case .Normal:
            groupType.stringValue = "Data independent loop"
            loopCount.isHidden = false
            loopCountText.isHidden = false
            loopCount.integerValue = tmpGroupAttribute.loopCount!
            break
        case .ACI:
            groupType.stringValue = "Data dependent loop"
            loopCount.isHidden = false
            loopCountText.isHidden = false
            loopCount.stringValue = "?"
            break
        default:
            loopCount.isHidden = true
            loopCountText.isHidden = true
            break
        }
        nodesOfGroupTableView.reloadData()
    }
    
}

extension groupGlobalAttributeViewController: NSTextFieldDelegate {
    override func controlTextDidChange(_ obj: Notification) {
        tmpGroupAttribute.name = name.stringValue
    }
}

extension groupGlobalAttributeViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return (tmpGroupAttribute as GraphElement).children.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if tableColumn == tableView.tableColumns[0] {
            return (tmpGroupAttribute as GraphElement).children[row].name
        } else if tableColumn == tableView.tableColumns[1] {
            return String((tmpGroupAttribute as GraphElement).children[row].children.count)
        } else {
            return nil
        }
    }
}
