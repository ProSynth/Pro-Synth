//
//  ResultSelector.swift
//  Pro Synth
//
//  Created by Markovits Gergő on 2017. 11. 28..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

class ResultSelector: NSViewController {

    var numberOfSchedules: Int = 2
    
    @IBOutlet weak var tableView: NSScrollView!
    @IBOutlet weak var ResultTableView: NSTableView!
    
    @IBAction func close(_ sender: Any) {
    }
    @IBAction func select(_ sender: Any) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}

extension ResultSelector: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return numberOfSchedules
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if tableColumn == ResultTableView.tableColumns[0] {
            //ResultTableView.make
            if let cell = ResultTableView.make(withIdentifier: "SelectCell", owner: nil) as? SelecResultCell {
                cell.selectSched.title = "Ütemezés"
                return cell
            }
        }
        return nil
    }
    
    
}
