//
//  Document.swift
//  Pro Synth
//
//  Created by Gergo Markovits on 2017. 08. 17..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

class Document: NSDocument {
    


    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }

    override class func autosavesInPlace() -> Bool {
        return true
    }

    override func makeWindowControllers() {
        
        
        
        
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: "Document Window Controller") as! NSWindowController
        self.addWindowController(windowController)
    }

    override func data(ofType typeName: String) throws -> Data {
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
       NotificationCenter.default.post(name: Notification.Name("saveFile"), object: self)
        return Data(bytes: [0x23, 0x34, 0x56])
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
        // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
        // If you override either of these, you should also override -isEntireFileLoaded to return false if the contents are lazily loaded.
        fileData = [UInt8](data)
        NotificationCenter.default.post(name: Notification.Name("readFile"), object: self)
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

 
}

/*
 do {
 print("Getting the bytes of an instance")
 let _name : [UInt8] = [32, 32, 32, 32]
 
 var sampleStruct = GroupData(groupID: 9, numberOfNodes: 12, maxTime: 3, loop: .Normal, loopCount: 200)
 
 withUnsafeBytes(of: &sampleStruct) { bytes in
 for byte in bytes {
 print(byte)
 }
 }
 }
 
 var str = "Pro Synth"
 var byteArray = [UInt8]()
 for char in str.utf8{
 byteArray += [char]
 }
 print(byteArray)
 */

