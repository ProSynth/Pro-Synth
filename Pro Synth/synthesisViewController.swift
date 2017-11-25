//
//  synthesisViewController.swift
//  Pro Synth
//
//  Created by Markovits Gergő on 2017. 11. 12..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

struct SchedulingElement {
    var index: Int
    static var stindex: Int = 0
    var restartTime: Int
    var latency: Int
    var name: String {
        get {
            return "\(index) -> Restart: \(String(restartTime)) + Latency: \(String(latency))"
        }
        set(specialName){
            self.name = specialName
        }
    }
    init(restartTime: Int, latency: Int) {
        self.restartTime = restartTime
        self.latency = latency
        SchedulingElement.stindex += 1
        self.index = SchedulingElement.stindex
    }
}

protocol StartSynthDelegate {
    func DoRSCUUnrolling(splitInto segment: Int, with decTool: RSCUDecType) -> (recursionDepth: Int, numOfNode: Int, maxWeight: Int)
    func DoWNCutDecomposing(parameter: Double, useWeights: Bool) -> (disjunktGroups: Int, numOfNode: Int, sumEdgeWeights: Int)
    func DoSpecFDS(p: Bool, s: Bool, d: Bool, schedules: [SchedulingElement], useSpectrum: Bool) -> [Int]
}

class synthesisViewController: NSViewController {

    var delegate:StartSynthDelegate?
    
    var selected: String = ""
    
    var Schedules = [SchedulingElement]()
    var currentLatency: Int = 0
    var currentRestartTime: Int = 0
    var selectedScheduleIndex: Int = 0
    
    @IBAction func SynthSelect(_ sender: NSButton) {
        selected = sender.title
        print(selected)
    }
    
    
    
    
    @IBOutlet weak var WNCutParameter: NSTextField!
    @IBOutlet weak var WNCutWeighted: NSButton!
    @IBOutlet weak var WNCutSave: NSButton!
    @IBOutlet weak var WNCutNumOfGroups: NSTextField!
    @IBOutlet weak var WNCutNumOfNodes: NSTextField!
    @IBOutlet weak var WNCutSumOfEWeights: NSTextField!
    
    @IBOutlet weak var RSCUTaskSplitTextField: NSTextField!
    @IBOutlet weak var RSCUTaskSplitStepper: NSStepper!
    @IBOutlet weak var RSCUDecomposingToolSelector: NSPopUpButton!
    @IBOutlet weak var RSCUSave: NSButton!
    @IBOutlet weak var RSCURecursionDepth: NSTextField!
    @IBOutlet weak var RSCUNumOfNodes: NSTextField!
    @IBOutlet weak var RSCUBiggestWeight: NSTextField!
    
    @IBOutlet weak var SpectFDirRestartTime: NSTextField!
    @IBOutlet weak var SpectFDirLatency: NSTextField!
    @IBOutlet weak var SpectFDirParamP: NSButton!
    @IBOutlet weak var SpectFDirParamS: NSButton!
    @IBOutlet weak var SpectFDirParamD: NSButton!
    @IBOutlet weak var SpectFDirSave: NSButton!
    @IBOutlet weak var SpectFDirMaxProc: NSTextField!
    @IBOutlet weak var SpectFDirMultipleSchedSelector: NSPopUpButton!
    @IBOutlet weak var SpectFDirAddRemoveSynth: NSSegmentedControl!
    @IBOutlet weak var SpectFDirRestartTimeSteps: NSTextField!
    @IBOutlet weak var SpectFDirRestartTimeStepsStepper: NSStepper!
    @IBOutlet weak var autoFill: NSButton!
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "autoFill" {
            
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        SynthViewController = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.StartSynth), name: Notification.Name("startSynth"), object: nil)
        NotificationCenter.default.post(name: Notification.Name("synthDidLoad"), object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.AutofillPaste), name: Notification.Name("autoFillCompleted"), object: nil)
        Schedules.append(SchedulingElement(restartTime: 0, latency: 0))
        SpectFDirMultipleSchedSelector.removeAllItems()
        SpectFDirMultipleSchedSelector.addItem(withTitle: Schedules[0].name)
        SpectFDirAddRemoveSynth.setEnabled(false, forSegment: 1)
    }
    
    @IBAction func ScheduleChanged(_ sender: NSPopUpButton) {
        selectedScheduleIndex = sender.indexOfSelectedItem
        SpectFDirLatency.integerValue = Schedules[SpectFDirMultipleSchedSelector.indexOfSelectedItem].latency
        SpectFDirRestartTime.integerValue = Schedules[SpectFDirMultipleSchedSelector.indexOfSelectedItem].restartTime
    }
    
    func StartSynth() {
        




        
        switch selected {
        case "WNCut":
            let parameter: Double = Double(WNCutParameter.floatValue)
            let useWeights: Bool = (WNCutWeighted.state == NSOnState ? true : false)
            // Dekompozíció thread indítása
            DispatchQueue.global(qos: .userInteractive).async {
                let result = self.delegate?.DoWNCutDecomposing(parameter: parameter, useWeights: useWeights)
                DispatchQueue.main.async {
                    self.WNCutNumOfNodes.integerValue = (result?.numOfNode)!
                    self.WNCutNumOfGroups.integerValue = (result?.disjunktGroups)!
                    self.WNCutSumOfEWeights.integerValue = (result?.sumEdgeWeights)!
                }
            }
            
            break
        case "RSCU":
            
            let segments: Int = RSCUTaskSplitTextField.integerValue
            DispatchQueue.global(qos: .userInteractive).async {
                let result = self.delegate?.DoRSCUUnrolling(splitInto: segments, with: .FastWNCut)
                DispatchQueue.main.async {
                    self.RSCUBiggestWeight.integerValue = (result?.maxWeight)!
                    self.RSCURecursionDepth.integerValue = (result?.recursionDepth)!
                    self.RSCUNumOfNodes.integerValue = (result?.numOfNode)!
                }
            }
            
            break
        case "SFDS":
            DispatchQueue.global(qos: .userInteractive).async {
                let result = self.delegate?.DoSpecFDS(p: true, s: true, d: true, schedules: self.Schedules, useSpectrum: true)
                DispatchQueue.main.async {
                    self.SpectFDirMaxProc.stringValue = ""
                    for i in 0..<(result?.count)! {
                        self.SpectFDirMaxProc.stringValue += "\(i).: \(result![i])    "
                    }
                }
            }
            break
        default:
            break
        }
    }
    @IBAction func autoFill(_ sender: Any) {
        
    }
    
    func AutofillPaste() {
        Schedules = schedulesArray
        SpectFDirMultipleSchedSelector.removeAllItems()
        for i in 0..<Schedules.count {
            SpectFDirMultipleSchedSelector.addItem(withTitle: (Schedules[i].name))
        }
        selectedScheduleIndex = 0
        SpectFDirMultipleSchedSelector.selectItem(at: selectedScheduleIndex)
        SpectFDirLatency.integerValue = Schedules[SpectFDirMultipleSchedSelector.indexOfSelectedItem].latency
        SpectFDirRestartTime.integerValue = Schedules[SpectFDirMultipleSchedSelector.indexOfSelectedItem].restartTime
        
        for i in 0..<Schedules.count {
            Schedules[i].index = i+1
            SpectFDirMultipleSchedSelector.removeItem(at: i)
            SpectFDirMultipleSchedSelector.insertItem(withTitle: Schedules[i].name, at: i)
        }
        SchedulingElement.stindex -= 1
    }
    
    @IBAction func AddRemoveScheduling(_ sender: NSSegmentedControl) {

        switch sender.indexOfSelectedItem {
        case 0:
            Schedules.append(SchedulingElement(restartTime: 0, latency: 0))
            SpectFDirMultipleSchedSelector.addItem(withTitle: (Schedules.last?.name)!)
            //selectedScheduleIndex = SpectFDirMultipleSchedSelector.indexOfItem(withTitle: (Schedules.last?.name)!)
            SpectFDirMultipleSchedSelector.selectItem(at: Schedules.count-1)
            SpectFDirLatency.stringValue = ""
            SpectFDirRestartTime.stringValue = ""
            selectedScheduleIndex = SpectFDirMultipleSchedSelector.indexOfSelectedItem
            break
        case 1:
            selectedScheduleIndex = SpectFDirMultipleSchedSelector.indexOfSelectedItem
            Schedules.remove(at: SpectFDirMultipleSchedSelector.indexOfSelectedItem)
            SpectFDirMultipleSchedSelector.removeItem(at: SpectFDirMultipleSchedSelector.indexOfSelectedItem)
            
            SpectFDirMultipleSchedSelector.selectItem(at: Schedules.count-1)
            SpectFDirLatency.integerValue = Schedules[SpectFDirMultipleSchedSelector.indexOfSelectedItem].latency
            SpectFDirRestartTime.integerValue = Schedules[SpectFDirMultipleSchedSelector.indexOfSelectedItem].restartTime
            selectedScheduleIndex = SpectFDirMultipleSchedSelector.indexOfSelectedItem
            for i in 0..<Schedules.count {
                Schedules[i].index = i+1
                SpectFDirMultipleSchedSelector.removeItem(at: i)
                SpectFDirMultipleSchedSelector.insertItem(withTitle: Schedules[i].name, at: i)
            }
            SchedulingElement.stindex -= 1
            break
        default:
            break
        }
        
        if Schedules.count < 2 {
            sender.setEnabled(false, forSegment: 1)
        } else {
            sender.setEnabled(true, forSegment: 1)
        }
        if Schedules.count > 7 {
            sender.setEnabled(false, forSegment: 0)
        } else {
            sender.setEnabled(true, forSegment: 0)
        }
    }
}

extension synthesisViewController: NSTextFieldDelegate {
    override func controlTextDidChange(_ obj: Notification) {
        selectedScheduleIndex = SpectFDirMultipleSchedSelector.indexOfSelectedItem
        Schedules[selectedScheduleIndex].latency = SpectFDirLatency.integerValue
        Schedules[selectedScheduleIndex].restartTime = SpectFDirRestartTime.integerValue
        
        SpectFDirMultipleSchedSelector.removeItem(at: selectedScheduleIndex)
        SpectFDirMultipleSchedSelector.insertItem(withTitle: Schedules[selectedScheduleIndex].name, at: selectedScheduleIndex)
        SpectFDirMultipleSchedSelector.selectItem(at: selectedScheduleIndex)
    }
}
