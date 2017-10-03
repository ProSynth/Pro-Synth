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

        
        /* Oldalsáv kezelése */
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideGraphSidebar), name: Notification.Name("hideGraphSidebar"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showGraphSidebar), name: Notification.Name("showGraphSidebar"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideAttrSidebar), name: Notification.Name("hideAttrSidebar"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showAttrSidebar), name: Notification.Name("showAttrSidebar"), object: nil)
    }
    
    @objc func showGraphSidebar()  {
        graphViewItem.animator().isCollapsed = false
    }
    
    @objc func hideGraphSidebar()  {
        graphViewItem.animator().isCollapsed = true
    }
    
    @objc func showAttrSidebar()  {
        attributesViewItem.animator().isCollapsed = false
    }
    
    @objc func hideAttrSidebar()  {
        attributesViewItem.animator().isCollapsed = true
    }
}
