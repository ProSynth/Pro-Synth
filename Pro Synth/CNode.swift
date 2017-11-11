//
//  CNode.swift
//  Pro Synth
//
//  Created by Pro Synth on 2017. 11. 10..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

class CNode: NSObject {
    
    let id: Int!
    let type: String!
    let latency: Int!
    var asap: Int
    var alap: Int
    var origAsap: Int!
    var origAlap: Int!
    
    // Az eredeti fájlban itt kezdődnek a public változók
    var transfers   = [Int]()
    var prd         = [Int]()
    var nxt         = [Int]()
    
    init(NodeID: Int, Name: String, Weight: Int) {
        self.id = NodeID
        self.type = Name
        self.latency = Weight
        
        self.asap = -1
        self.alap = -1
        
        super.init()
    }
    
    
    
}
