//
//  GraphElement.swift
//  Pro Synth
//
//  Created by Gergo Markovits on 2017. 08. 28..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa



//////////////////////////////////////////////////////////////////////////////////////
//!         Class
//////////////////////////////////////////////////////////////////////////////////////
//!         GraphElement
//!===================================================================================
//!         Leírás: Az egyes gráfelemeknek (csoport, pont, él) őse (superclassa)
//!                 Tartalmazza: a nevet                                {name}
//!                              a hozzákapcsolódó további gráfelemeket {children}
//////////////////////////////////////////////////////////////////////////////////////

class GraphElement: NSObject {
    dynamic var name: String
    dynamic var parent: GraphElement
    dynamic var children = [GraphElement] ()
    
//////////////////////////////////////////////////////////////////////////////////////
//!         Functions
//////////////////////////////////////////////////////////////////////////////////////
//!         init()
//!===================================================================================
//!         Leírás: A superclassban csak a nevet inicializáljuk, és a subclassban pedig
//!                 meghívjuk super.init() néven
//////////////////////////////////////////////////////////////////////////////////////
    
    init(name: String, parent: GraphElement) {                            //Inicializáljuk a superclass-t a nevével
        self.name = name
    }
    

//////////////////////////////////////////////////////////////////////////////////////
//!         getName()
//!===================================================================================
//!         Leírás: Ez a függvény a Graphelement objektum nevének a meghatározása
//!                 miatt kell
//////////////////////////////////////////////////////////////////////////////////////
    
    func getName() -> String {
        return self.name
    }
    
}
