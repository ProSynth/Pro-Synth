//
//  welcomeCollectionViewItem.swift
//  document based
//
//  Created by Gergo Markovits on 2017. 08. 16..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

class welcomeCollectionViewItem: NSCollectionViewItem {

    @IBOutlet weak var projectTitle: NSTextField!       //Projekt cím
    @IBOutlet weak var projectPath: NSTextField!        //Elérési útvonal
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.wantsLayer = true                          //Layerkompatibilisre állítjuk, hogy mindegyik példány külön layeren legyen
        view.layer?.backgroundColor = NSColor.clear.cgColor     //Átlátszóra állítjuk a hátteret
        projectPath.textColor = NSColor.gray            //Az elérési utat megtesszük szürkének
        
    }
    
    func setHighlight(selected:Bool) {
        if selected {
            view.layer?.backgroundColor = NSColor.selectedMenuItemColor.cgColor
            projectTitle.textColor = NSColor.white
            projectTitle.backgroundColor = NSColor.clear
            projectPath.textColor = NSColor.white
        } else {
            view.layer?.backgroundColor = NSColor.clear.cgColor
            projectTitle.textColor = NSColor.black
            projectPath.textColor = NSColor.gray
        }
    }
    
}
