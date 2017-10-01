//
//  groupAttributeViewController.swift
//  Pro Synth
//
//  Created by Gergo Markovits on 2017. 09. 23..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

class groupAttributeViewController: NSSplitViewController {

    @IBOutlet weak var groupGlobalAttribute: NSSplitViewItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        NSLayoutConstraint(item: groupGlobalAttribute.viewController.view, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 285)
    }
    
}
