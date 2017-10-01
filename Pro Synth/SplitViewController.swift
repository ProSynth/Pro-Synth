//
//  SplitViewController.swift
//  Pro Synth
//
//  Created by Gergo Markovits on 2017. 10. 01..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

class SplitViewController: NSSplitViewController {

    @IBOutlet weak var graphViewItem: NSSplitViewItem!
    @IBOutlet weak var mainViewItem: NSSplitViewItem!
    @IBOutlet weak var attributesViewItem: NSSplitViewItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        NSLayoutConstraint(item: attributesViewItem.viewController.view, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 285)
        
        NSLayoutConstraint(item: graphViewItem.viewController.view, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 245)
    }
    
}
