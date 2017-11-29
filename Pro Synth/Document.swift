//
//  Document.swift
//  Pro Synth
//
//  Created by Gergo Markovits on 2017. 08. 17..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

var isReady = false

class Document: NSDocument {
    


    override init() {
        super.init()
        // Add your subclass-specific initialization here.
        NotificationCenter.default.addObserver(self, selector: #selector(self.closeFirstWindow), name: Notification.Name("closeFirstWindow"), object: nil)
    }

    override class func autosavesInPlace() -> Bool {
        return true
    }

    override func makeWindowControllers() {
        
        
        
        
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: "Document Window Controller") as! NSWindowController
        self.addWindowController(windowController)
        welcomeWindowController?.close()
    }

    override func data(ofType typeName: String) throws -> Data {
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
       NotificationCenter.default.post(name: Notification.Name("saveFile"), object: self)
        while !isReady {
            
        }
        isReady = false
        return Data(bytes: stackBytes)
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
        // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
        // If you override either of these, you should also override -isEntireFileLoaded to return false if the contents are lazily loaded.
        fileData = [UInt8](data)
        
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: "Document Window Controller") as! NSWindowController
        self.addWindowController(windowController)
        
        welcomeWindowController?.close()
        if fileData.count < 12 {
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        } else {
            NotificationCenter.default.post(name: Notification.Name("readFile"), object: self)
        }
        
        (windowControllers[0] as? WindowController)?.windowName.stringValue = self.displayName
        //windowControllers[windowControllers.count-2].close()
        /*print(windowControllers.count)
        for i in 0..<windowControllers.count {
            print(windowControllers[i].window?.title)
        }*/
    }
    
    func closeFirstWindow() {
        windowControllers[0].close()
    }

}


