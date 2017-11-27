//
//  SchedulingResultViewController.swift
//  Pro Synth
//
//  Created by Markovits Gergő on 2017. 11. 27..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Foundation
import Cocoa
import Charts

struct ScheduleResults {
    var name: String
    var graph: [GraphElement]
    var processorUsage: [Int]
}

class SchedulingResultViewController: NSViewController {


    @IBOutlet weak var lineChartView: LineChartView!
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
            lineChartView.isHidden = true
        } else {
            lineChartView.isHidden = false
        }
        
        let e1 = ChartDataEntry(x: 1.0, y: 2.3)
        let e2 = ChartDataEntry(x: 2.0, y: 3.8)
        let e3 = ChartDataEntry(x: 3.0, y: 5.4)
        let e4 = ChartDataEntry(x: 4.0, y: 2.3)
        let e5 = ChartDataEntry(x: 5.0, y: 3.4)
        
        let dataset = LineChartDataSet(values: [e1, e2, e3, e4, e5], label: "Ütemezés")
        dataset.colors = [NSUIColor.red]
        let data = LineChartData(dataSets: [dataset])
        lineChartView.data = data
        lineChartView.chartDescription?.text = "Processzorhasználat"
        
    }
    
    override func viewDidAppear() {
        if schedulesCount > 0 {
            lineChartView.isHidden = true
        } else {
            lineChartView.isHidden = false
        }
    }
    

    
}

