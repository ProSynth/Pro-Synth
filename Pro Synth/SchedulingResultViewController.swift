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
    var latency: Int
    var restartTime: Int
    var allGroupsIndex: UInt16
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
        //self.view.window?.title = "Pro Synth - Processor Usage"
        
        if schedulesCount > 0 {
            lineChartView.isHidden = false
        } else {
            lineChartView.isHidden = true
        }
        
        
        
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ResultSelector" , let vc = segue.destinationController as? ResultSelector {
            
        }
    }
    
    override func viewDidAppear() {
        self.view.window?.title = "Pro Synth - Processor Usage"
        if schedulesCount > 0 {
            lineChartView.isHidden = false
            NoSchedulingText.isHidden = true
            
            var circleColors: [NSUIColor] = []
            for i in 0..<schedulesCount {
                let red   = Double(arc4random_uniform(256))
                let green = Double(arc4random_uniform(256))
                let blue  = Double(arc4random_uniform(256))
                
                let color = NSUIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
                circleColors.append(color)
            }
            
            var chartDatas = [ChartDataEntry]()
            var datasets = [LineChartDataSet]()
            
            for j in 0..<tableData.count {
                for i in 0..<tableData[j].processorUsage.count {
                    chartDatas.append(ChartDataEntry(x: Double(i), y: Double(tableData[j].processorUsage[i])))
                }
                datasets.append(LineChartDataSet(values: chartDatas, label: "Scheduling: Restart time: \(tableData[j].restartTime), Latency: \(tableData[j].latency)"))
                chartDatas.removeAll()
                datasets.last?.colors = [circleColors[j]]
            }
            
            
            let data = LineChartData(dataSets: datasets)
            lineChartView.data = data
            lineChartView.chartDescription?.text = ""
            
        } else {
            lineChartView.isHidden = true
            NoSchedulingText.isHidden = false
        }

    }
    @IBAction func save(_ sender: Any) {
        let panel = NSSavePanel()
        panel.allowedFileTypes = ["png"]
        panel.beginSheetModal(for: self.view.window!) { (result) -> Void in
            if result.hashValue == NSFileHandlingPanelOKButton
            {
                if let path = panel.url?.path
                {
                    let _ = self.lineChartView.save(to: path, format: .png, compressionQuality: 1.0)
                }
            }
        }
    }
    // Grafikon adatok mentése
    @IBAction func saveData(_ sender: Any) {
        let myFiledialog = NSSavePanel()
        myFiledialog.prompt = "Save"
        myFiledialog.allowedFileTypes = ["txt"]
        
        myFiledialog.beginSheetModal(for: NSApplication.shared().mainWindow!, completionHandler: { num in
            if num == NSModalResponseOK {
                exportGraphPath = myFiledialog.url
                //NotificationCenter.default.post(name: Notification.Name("saveSynthesisMethod"), object: self)
                
                
                var text = ""
                for i in 0..<self.tableData.count
                {
                    for j in 0..<self.tableData[i].processorUsage.count
                    {
                        
                        text += String(j)
                        text += "   "
                        
                        
                        text += String((self.tableData[i].processorUsage[j]))
                        

                        text += "\n"
                    }
                    
                }
                
                if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    
                    //let fileURL = dir.appendingPathComponent(file)
                    
                    //writing
                    do {
                        try text.write(to: exportGraphPath!, atomically: false, encoding: .utf8)
                    }
                    catch {/* error handling here */}
                    
                    
                }
                
                
            } else {
                print("nothing chosen")
            }
        })
    }
    override open func viewWillAppear()
    {
        self.lineChartView.animate(xAxisDuration: 0.0, yAxisDuration: 1.0)
    }
    
}

