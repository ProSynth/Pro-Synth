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
    var groupAttributeViewController : groupAttributeViewController!
    var edgeAttributeViewController : edgeAttributeViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        noSelectionViewController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "noSelection") as! noSelectionViewController
        nodeAttributeViewController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "nodeAttribute") as! nodeAttributeViewController
        groupAttributeViewController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "groupAttribute") as! groupAttributeViewController
        edgeAttributeViewController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "edgeAttribute") as! edgeAttributeViewController
        
        self.addChildViewController(noSelectionViewController)
        self.addChildViewController(nodeAttributeViewController)
        self.addChildViewController(groupAttributeViewController)
        self.addChildViewController(edgeAttributeViewController)
        
        noSelectionViewController.view.frame = self.container.bounds
        self.container.addSubview(noSelectionViewController.view)
 
        NotificationCenter.default.addObserver(self, selector: #selector(self.switchToNode), name: Notification.Name("nodeAttribute"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.switchToGroup), name: Notification.Name("groupAttribute"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.switchToEdge), name: Notification.Name("edgeAttribute"), object: nil)
    }
    
    func switchToNode() {
        for sView in self.container.subviews {
            sView.removeFromSuperview()
        }
        
        nodeAttributeViewController.view.frame = self.container.bounds
        self.container.addSubview(nodeAttributeViewController.view)
    }

    func switchToGroup() {
        for sView in self.container.subviews {
            sView.removeFromSuperview()
        }
        
        groupAttributeViewController.view.frame = self.container.bounds
        self.container.addSubview(groupAttributeViewController.view)
    }
    
    func switchToEdge() {
        for sView in self.container.subviews {
            sView.removeFromSuperview()
        }
        print("idáig eljutott")
        edgeAttributeViewController.view.frame = self.container.bounds
        self.container.addSubview(edgeAttributeViewController.view)
        print("ez pedig már utána van")
    }
    
}
