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
    @IBOutlet weak var noSynthText: NSTextField!
    @IBOutlet weak var spectralValueText: NSTextField!
    @IBOutlet weak var startTimeText: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.update), name: Notification.Name("nodeAttribute"), object: nil)
        update()

    }
    
    func update() {
        if nil != tmpNodeAttribute.spectrum {
            SpectralValue.doubleValue = tmpNodeAttribute.spectrum!
        }
        if nil != tmpNodeAttribute.startTime {
            StartTime.integerValue = tmpNodeAttribute.startTime!
        }
        if (nil == tmpNodeAttribute.spectrum) && (nil == tmpNodeAttribute.startTime) {
            noSynthText.isHidden = false
            startTimeText.isHidden = true
            StartTime.isHidden = true
            spectralValueText.isHidden = true
            SpectralValue.isHidden = true
        } else {
            noSynthText.isHidden = true
            startTimeText.isHidden = false
            StartTime.isHidden = false
            spectralValueText.isHidden = false
            SpectralValue.isHidden = false
        }
    }
}
