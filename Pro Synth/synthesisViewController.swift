//
//  synthesisViewController.swift
//  Pro Synth
//
//  Created by Markovits Gergő on 2017. 11. 12..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

protocol StartSynthDelegate {
    func DoRSCUUnrolling(splitInto segment: Int, with decTool: RSCUDecType) -> (recursionDepth: Int, numOfNode: Int, maxWeight: Int)
    func DoWNCutDecomposing(parameter: Double, useWeights: Bool)
    func DoSpecFDS(restartTime: Int, latency: Int, p: Bool, s: Bool, d: Bool)
}

class synthesisViewController: NSViewController {

    var delegate:StartSynthDelegate?
    
    @IBAction func SynthSelect(_ sender: NSButton) {
        switch sender.title {
        case "WNCut":
            synthProcess = .WNCut
        case "RSCU":
            synthProcess = .RSCU
            break
        case "SFDS":
            synthProcess = .SFDS
            break
        default:
            break
        }
    }
    
    @IBOutlet weak var SynthSelect: NSButton!
    
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        SynthViewController = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.StartSynth), name: Notification.Name("startSynth"), object: nil)
        NotificationCenter.default.post(name: Notification.Name("synthDidLoad"), object: self)
    }
    
    func StartSynth() {
        
        
        let segments: Int = RSCUTaskSplitTextField.integerValue
        DispatchQueue.global(qos: .userInteractive).async {
            let result = self.delegate?.DoRSCUUnrolling(splitInto: segments, with: .FastWNCut)
            DispatchQueue.main.async {
                self.RSCUBiggestWeight.integerValue = (result?.maxWeight)!
                self.RSCURecursionDepth.integerValue = (result?.recursionDepth)!
                self.RSCUNumOfNodes.integerValue = (result?.numOfNode)!
            }
        }


        
        switch SynthSelect.title {
        case "WNCut":
            break
        case "RSCU":
            break
        case "SFDS":
            break
        default:
            break
        }
    }
    
}
