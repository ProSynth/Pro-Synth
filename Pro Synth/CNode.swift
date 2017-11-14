
import Cocoa

class CNode: NSObject {
    
    let id: Int!
    let type: String!
    let latency: Int!
    var asap: Int
    var alap: Int
    var origAsap: Int!
    var origAlap: Int!
    var IOTypeS: IO!
    var IOTypeL: IO!
    
    // Saját változó
    let groupPath: IndexPath!
    
    // Az eredeti fájlban itt kezdődnek a public változók
    var transfers   = [Int]()
    var prd         = [Int]()
    var nxt         = [Int]()
    
    init(NodeID: Int, Name: String, Weight: Int, type: IO, groupPath: IndexPath) {
        self.id = NodeID
        self.type = Name
        self.latency = Weight
        self.IOTypeS = type
        self.IOTypeL = type
        self.groupPath = groupPath
        
        self.asap = -1
        self.alap = -1
        
        super.init()
    }
    
    
    
}
