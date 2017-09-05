//
//  welcomeScreenViewController.swift
//  Pro Synth
//
//  Created by Gergo Markovits on 2017. 08. 17..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

let welcomeProjNumber = 9

class welcomeScreenViewController: NSViewController, NSCollectionViewDataSource, NSCollectionViewDelegate {
    
    @IBAction func openProjects(_ sender: NSButtonCell) {
        
        let filePicker:NSOpenPanel = NSOpenPanel()
        
        filePicker.canChooseFiles = true
        filePicker.allowsMultipleSelection = false
        filePicker.allowedFileTypes = ["sth"]
        
        filePicker.runModal()
        
    }

    @IBOutlet weak var welcomeCollectionView: NSCollectionView!
    @IBOutlet weak var noRecent: NSTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        let item = NSNib(nibNamed: "welcomeCollectionViewItem", bundle: nil)
        
        welcomeCollectionView.register(item, forItemWithIdentifier: "welcomeCollectionViewItem")
        welcomeCollectionView.dataSource = self
        welcomeCollectionView.delegate = self
        
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return welcomeProjNumber
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: "welcomCollectionViewItem", for: indexPath)
        return item
    }
    
}


