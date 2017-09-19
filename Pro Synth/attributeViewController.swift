//
//  attributeViewController.swift
//  Pro Synth
//
//  Created by Gergo Markovits on 2017. 09. 16..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

class attributeViewController: NSViewController {

    @IBOutlet weak var container: NSView!
    
    var noSelectionViewController : noSelectionViewController!
    var nodeAttributeViewController : nodeAttributeViewController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        noSelectionViewController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "noSelection") as! noSelectionViewController
        nodeAttributeViewController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "nodeAttribute") as! nodeAttributeViewController
        
        self.addChildViewController(noSelectionViewController)
        self.addChildViewController(nodeAttributeViewController)
        
        noSelectionViewController.view.frame = self.container.bounds
        self.container.addSubview(noSelectionViewController.view)
 
    }
    

    @IBAction func change(_ sender: Any) {
        for sView in self.container.subviews {
            sView.removeFromSuperview()
        }
        
        nodeAttributeViewController.view.frame = self.container.bounds
        self.container.addSubview(nodeAttributeViewController.view)
    }
    
    
}
