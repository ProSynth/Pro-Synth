//
//  SchedulingResultViewController.swift
//  Pro Synth
//
//  Created by Markovits Gergő on 2017. 11. 27..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

struct ScheduleResults {
    var name: String
    var graph: [GraphElement]
    var processorUsage: [Int]
}

class SchedulingResultViewController: NSViewController {

    @IBOutlet weak var ScrollView: NSScrollView!
    @IBOutlet weak var TableView: NSTableView!
    @IBOutlet weak var NoSchedulingText: NSTextField!
    
    @IBOutlet weak var selectSynth: NSPopUpButton!
    @IBAction func addSynth(_ sender: Any) {
    }
    
    
    var tableData = [ScheduleResults]()
    var schedulesCount: Int {
        get {
            return tableData.count
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.view.window?.title = "Pro Synth - Processor Usage"
        if schedulesCount > 0 {
            ScrollView.isHidden = true
        } else {
            ScrollView.isHidden = false
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload), name: Notification.Name("updateProcessorUsage"), object: nil)
    }
    
    override func viewDidAppear() {
        if schedulesCount > 0 {
            ScrollView.isHidden = true
        } else {
            ScrollView.isHidden = false
        }
    }
    
    func reload() {
        
        TableView.reloadData()
        var maxColumnCount: Int = 0
        for i in 0..<tableData.count {
            if tableData[i].processorUsage.count > maxColumnCount {
                maxColumnCount = tableData[i].processorUsage.count
            }
        }
        
    }
    
}
extension SchedulingResultViewController: NSTableViewDataSource {
    
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return schedulesCount
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if tableColumn == TableView.tableColumns[0] {
            return tableData[row].name
        }
        
        /*
        for i in 1..<tableData[row].processorUsage.count {
            if tableColumn == TableView.tableColumns[i] {
                return tableData[row].processorUsage[i]
            }
        }
 */
        return tableData[row].processorUsage[1]
        return nil
    }
    
    
}

extension SchedulingResultViewController: NSTableViewDelegate {
    
}
