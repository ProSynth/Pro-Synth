//
//  autoFill.swift
//  Pro Synth
//
//  Created by Markovits Gergő on 2017. 11. 25..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

class autoFill: NSViewController {

    var selected: String? = nil
    
    @IBOutlet weak var from: NSTextField!
    @IBOutlet weak var to: NSTextField!
    @IBOutlet weak var resolution: NSTextField!
    @IBOutlet weak var count: NSTextField!
    @IBOutlet weak var countStepper: NSStepper!
    @IBOutlet weak var other: NSTextField!
    @IBOutlet weak var otherValue: NSTextField!
    

  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        count.integerValue = countStepper.integerValue
        countStepper.maxValue = 1000
        resolution.integerValue = 1
    }
    
    @IBAction func create(_ sender: Any) {
        
        if from.integerValue > to.integerValue {
            let alert = NSAlert()
            alert.messageText = "Hiba!"
            alert.informativeText = "A kezdeti érték nagyobb, mint a végérték!"
            alert.addButton(withTitle: "OK")
            alert.runModal()
            return
        }
        switch selected {
        case "restart time."?:
            for i in 0..<count.integerValue {
                schedulesArray.append(SchedulingElement(restartTime: (from.integerValue + (i * resolution.integerValue)), latency: otherValue.integerValue))
            }
            break
        case "latency."?:
            for i in 0..<count.integerValue {
                schedulesArray.append(SchedulingElement(restartTime: otherValue.integerValue, latency: (from.integerValue + (i * resolution.integerValue))))
            }
            break
        default:
            return
        }
        NotificationCenter.default.post(name: Notification.Name("autoFillCompleted"), object: self)
        dismissViewController(self)
        
    }
    
    @IBAction func close(_ sender: Any) {
    }
    
    @IBAction func iterationSelect(_ sender: NSButton) {
        selected = sender.title
        switch selected {
        case "restart time."?:
            other.stringValue = "Latency"
            break
        case "latency."?:
            other.stringValue = "Restart time"
            break
        default:
            return
        }
    }
    

    @IBAction func changeCount(_ sender: Any) {
        count.integerValue = countStepper.integerValue
        let _from =             from.integerValue
        var _resolution =       1
        if resolution.integerValue > 0 {
            _resolution =       resolution.integerValue
        }
        
        
        var _to =               to.integerValue
        var _count =            1
        if count.integerValue > 0 {
            _count =            count.integerValue
        }
        
        
        
        _to = _count * _resolution + _from
        
        
        from.integerValue =         _from
        resolution.integerValue =   _resolution
        to.integerValue =           _to
        if _count > 0 {
            count.integerValue =        _count
            countStepper.integerValue = _count
        }

    }
    
}

extension autoFill: NSTextFieldDelegate {
    override func controlTextDidChange(_ obj: Notification) {
        countStepper.integerValue = count.integerValue

        // A from és a timesteps mindig static típusok, soha nem változnak maguktól
        // A count és a to az, ami változhat
        
        //      Ha a to-t változtatják, akkor a count változik,
        //      Ha a count-ot változtatják, akkor a to változik
        
        let _from =             from.integerValue
        var _resolution =       1
        if resolution.integerValue > 0 {
             _resolution =       resolution.integerValue
        }
        

        var _to =               to.integerValue
        var _count =            1
        if count.integerValue > 0 {
            _count =            count.integerValue
        }

        
        if (obj.object as! NSTextField) == count {
            _to = _count * _resolution + _from
        } else if (obj.object as! NSTextField) == resolution {
            _count = (_to - _from) / _resolution
        } else {
            _count = (_to - _from) / _resolution
            _to = _count * _resolution + _from
        }
        
        from.integerValue =         _from
        resolution.integerValue =   _resolution
        to.integerValue =           _to
        if _count > 0 {
            count.integerValue =        _count
            countStepper.integerValue = _count
        }
    }
}
