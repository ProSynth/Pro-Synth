//
//  welcomeScreenWindowController.swift
//  Pro Synth
//
//  Created by Gergo Markovits on 2017. 08. 17..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

class welcomeScreenWindowController: NSWindowController {

    
    
    
    class func loadFromNib() -> welcomeScreenWindowController {
        let vc = NSStoryboard(name: "welcomScreen", bundle: nil).instantiateController(withIdentifier: "welcomeScreenWindowController") as! welcomeScreenWindowController
        return vc
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
        
        // Deklaráljuk az ablak beállításához az ablakot
        guard let window = window else {
            return
        }
        
        window.titlebarAppearsTransparent = true                //Áttetszővé tesszük a felső csíkot és az ablakkeretet
        window.titleVisibility = .hidden                        //Elrejtjük az ablak címét
        window.styleMask.insert(.fullSizeContentView)           //A view-al kitöltjük a teljes felületet
        window.styleMask.insert(.closable)                      //Bezárhatóvá tesszük azért mégis..
        window.backgroundColor = NSColor.white                  //Háttér fehér
        
        
        
        
    }

}
