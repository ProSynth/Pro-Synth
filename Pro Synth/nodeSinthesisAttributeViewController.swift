//
//  nodeSinthesisAttributeViewController.swift
//  Pro Synth
//
//  Created by Gergo Markovits on 2017. 10. 01..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

class nodeSinthesisAttributeViewController: NSViewController {

    @IBOutlet weak var SpectralValue: NSTextField!
    @IBOutlet weak var StartTime: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if nil != tmpNodeAttribute.spectrum {
            SpectralValue.doubleValue = tmpNodeAttribute.spectrum!
        }
        if nil != tmpNodeAttribute.startTime {
            StartTime.integerValue = tmpNodeAttribute.startTime!
        }
    }
    
    
}
