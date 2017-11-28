//
//  SpectralForceDirected.swift
//  Pro Synth
//
//  Created by Markovits Gergő on 2017. 11. 08..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa
import Accelerate
import simd

let EPS: Float      = 0.0005
let USE_QI          = 1
let USE_TI          = 0
let VERBOSE         = false

// Arguments:
// p :  include buffers in allocation estimation
// s :  choose first best-force cycle in case of a tie        ??????
// d :  delay scheduling operations with optimum ties
// v :  increase detail level in output

// Jelzések: //!!! --> Hiba lehetőség

class SpectralForceDirected: NSObject {
    // Saját változók definiálása
    var groups: [GraphElement]
    
    init(groups: [GraphElement]) {
        self.groups = groups
        super.init()
    }
    
    
    // Változók definiálása
    var maxdelayrounds: Int                 = 1
    var restartTime: Int                    = -1
    var l: Int                              = -1
    let PLUS_INF_FCE: Float                 = 1000000000
    let NOMAXDELAYROUNDS: UInt              = 1000000000            // Never used
    var argV: Bool                          = false
    
    var cpuusage            = [Int]()
    var maxusage : Int  = 1
    
    var transferTimeInfo                    = [Int : [Int]]()
    var usageCache                          = [Int : [Float]]()
    var w                                   = [String : Int]()
    var latencytime                         = 1
    // CNode osztály példányosítása
    var ops                                 = [CNode]()
    
    var spektrum: (Spectrum: [Double], Group: [Int], NodeIDCoder: [Int])!
    
    //////////////////////////////////////////////////////////////////////////////////////
    //!         Function readInput
    //!===================================================================================
    //!         Leírás: Adatok betöltése a gráfszerkezetből
    //!
    //////////////////////////////////////////////////////////////////////////////////////
    
    func readInput() {
        var tmpNode: CNode
        for i in 0..<groups.count {
            for j in 0..<groups[i].children.count {
                let id = (groups[i].children[j] as! Node).nodeID
                let weight = (groups[i].children[j] as! Node).weight
                let name = String("abbCPU")  //groups[i].children[j].name
                let IOType = (groups[i].children[j] as! Node).type
                let indexPath = IndexPath(indexes:[i, j])                           //MARK: -!!!
                tmpNode = CNode(NodeID: id, Name: name!, Weight: weight, type: IOType, groupPath: indexPath)
                ops.append(tmpNode)
            }
        }
        for i in 0..<groups.count {
            for j in 0..<groups[i].children.count {
                for k in 0..<groups[i].children[j].children.count {
                    let sNode = (groups[i].children[j].children[k] as! Edge).parentsNode.nodeID
                    let dNode = (groups[i].children[j].children[k] as! Edge).parentdNode.nodeID
                    if !ops[sNode].nxt.contains(dNode) {
                        ops[sNode].nxt.append(dNode)
                    }
                    if !ops[dNode].prd.contains(sNode) {
                        ops[dNode].prd.append(sNode)
                    }
                }
            }
        }
        //find ins and outs (for real)
        for i in 0..<ops.count {
            ops[i].IOTypeS = .Normal
            ops[i].IOTypeL = .Normal
            if ops[i].prd.count == 0 {
                ops[i].IOTypeS = .Input
            }
            if ops[i].nxt.count == 0 {
                ops[i].IOTypeL = .Output
            }
        }
        
    }
    
    
    func calculateAsapAlap(latencyTime: Int) {
        latencytime = latencyTime
        // Asap
        for i in 0..<ops.count {
            if ops[i].IOTypeS == .Input {
                ops[i].asap = 0
            }
        }
        for i in 0..<ops.count {
            if ops[i].IOTypeS == .Input {
                for j in 0..<ops[i].nxt.count {
                    if ops[ops[i].nxt[j]].asap < ops[i].asap + ops[i].latency {
                        ops[ops[i].nxt[j]].asap = ops[i].asap + ops[i].latency
                    }
                }
            }
        }
        var counter: Int = 1
        while counter > 0 {
            counter = 0
            for i in 0..<ops.count {
                if ((ops[i].asap != -1))  {
                    
                    for j in 0..<ops[i].nxt.count {
                        if ops[ops[i].nxt[j]].asap < (ops[i].asap + ops[i].latency ) {
                            ops[ops[i].nxt[j]].asap = ops[i].asap + ops[i].latency
                            counter += 1
                        }
                    }
                    
                }
            }
        }
        
        //get minimum possible latency, adjust accordingly
        for i in 0..<ops.count {
            if ((ops[i].asap+ops[i].latency) > latencytime)
            {
                latencytime = ops[i].asap+ops[i].latency
                print("\(ops[i].id!). miatt a tartható latency megnőtt L=\(latencytime).")
            }
            
        }
        
        //Alap
        for i in 0..<ops.count {
            if ops[i].IOTypeL == .Output {
                ops[i].alap = latencytime - ops[i].latency
            }
        }
        for i in 0..<ops.count {
            if ((ops[i].IOTypeL == .Output)) {
                for j in 0..<ops[i].prd.count {
                    if (ops[ops[i].prd[j]].alap > (ops[i].alap  - (ops[ops[i].prd[j]].latency)) || ops[ops[i].prd[j]].alap == -1) {
                        ops[ops[i].prd[j]].alap = ops[i].alap  - (ops[ops[i].prd[j]].latency)
                    }
                }
            }
        }
        
        
        
        
        counter = 1
        while counter > 0 {
            counter = 0
            for i in 0..<ops.count {
                if ( (ops[i].alap != -1)) {
                    
                    for j in 0..<ops[i].prd.count {
                        if (ops[ops[i].prd[j]].alap > (ops[i].alap - (ops[ops[i].prd[j]].latency)) || ops[ops[i].prd[j]].alap == -1) {
                            ops[ops[i].prd[j]].alap = ops[i].alap - (ops[ops[i].prd[j]].latency)
                            counter += 1
                        }
                    }
                    
                }
            }
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////
    //!         Function findL
    //!===================================================================================
    //!         Leírás: ???
    //!
    //////////////////////////////////////////////////////////////////////////////////////
    
    private func findL() {
        for i in 0..<ops.count {
            if ((ops[i].alap + ops[i].latency) > l) {
                l = ops[i].alap + ops[i].latency
            }
        }
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    //!         Function genTransfers
    //!===================================================================================
    //!         Leírás: (re)generate q(i)-related information for Cnode
    //!
    //////////////////////////////////////////////////////////////////////////////////////
    
    private func genTransfers() {
        for i in 0..<ops.count {
            ops[i].transfers.removeAll()
            ops[i].transfers.append(ops[i].asap)
            ops[i].transfers.append(ops[i].alap)
            for j in 0..<(ops[i].nxt.count) {
                ops[i].transfers.append(ops[ops[i].nxt[j]].asap)
                ops[i].transfers.append(ops[ops[i].nxt[j]].alap)
            }
        }
        //usage_qm() cache aid
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    //!         Function aFold
    //!===================================================================================
    //!         Leírás: afold(): fold an array to "overlapped" version (i.e., map L to R)
    //!
    //////////////////////////////////////////////////////////////////////////////////////
    // MARK: - a tömb referenciával van átadva. Direkt így van, vagy csak C++ hülyeség?
    
    private func aFold(arr: inout [Float]) -> [Float] {
        var tmp     = [Float]()
        if arr.count > restartTime {                            //no folding required if arr.size()<=restartTime
            var i: Int = 0
            tmp = Array(repeating: 0.0, count: restartTime)
            // inicializálatlan tömb, sebersségnövelés céllal
            for j in 0..<restartTime {
                tmp[i] += arr[j]
                i += 1
                if i == restartTime {                           //avoid modulo in the loop
                    i = 0
                }
            }
        }
        return tmp
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    //!         Function build_qi
    //!===================================================================================
    //!         Leírás: ???
    //!
    //////////////////////////////////////////////////////////////////////////////////////
    
    private func build_qi(e: CNode, t: Int, wgt: Float) -> [Float] {
        var follow      = [Float]()
        var nextAsap: Int
        var plusWgt: Float
        
        follow = Array(repeating: 0.0, count: 2*latencytime)                //ez nem 1
        nextAsap = t + e.latency  //kivettem a hurokból
        if follow[nextAsap] < wgt {
            follow[nextAsap] = wgt
        }
        
        for i in 0..<e.nxt.count {
            
            
            if (/*(ops[e.nxt[i]].type != "Buffer") &&*/ (nextAsap >= ops[e.nxt[i]].asap)) {
                plusWgt = wgt / (Float(1) + Float(ops[e.nxt[i]].alap) - Float(ops[e.nxt[i]].asap))
                if (ops[e.nxt[i]].latency > 2)
                {
                    for j in 2..<ops[e.nxt[i]].latency {
                        if follow[j + nextAsap-1] < plusWgt {
                            follow[j + nextAsap-1] = plusWgt
                        }
                    }
                }
            }
        }
        return follow
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    //!         Function addIP
    //!===================================================================================
    //!         Leírás: add to array in place
    //!
    //////////////////////////////////////////////////////////////////////////////////////
    // MARK: - Referenciával kell meghívni!!!
    
    private func addIp(a: inout [Float], b: [Float], wgt: Int = 1) -> [Float] {
        var maxIdx: Int!
        if a.count <= b.count {                                 // MARK:!!!
            maxIdx = a.count
        } else {
            maxIdx = b.count
        }
        if wgt == 1 {
            for i in 0..<maxIdx {
                a[i] += b[i]
            }
        } else {
            for i in 0..<maxIdx {
                a[i] += Float(wgt)*b[i]
            }
        }
        return a
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    //!         Function usageQm
    //!===================================================================================
    //!         Leírás: non-overlapped processor usage; caches result if required.
    //!
    //////////////////////////////////////////////////////////////////////////////////////
    
    private func usageQm(e: CNode, wgt: Float = 1, useWhichTime: Int = USE_QI) -> [Float] {
        var tmp             = [Float]()
        var test: Bool      = true
        
        if transferTimeInfo.index(forKey: e.id) != nil {          // MARK:!!! Itt mi a fenét akart az eredeti szerző???
            if transferTimeInfo[e.id]?.count == e.transfers.count {
                for i in 0..<e.transfers.count {
                    if transferTimeInfo[e.id]![i] != e.transfers[i] {
                        test = false
                    }
                }
            }
            if test == true {
                return usageCache[e.id]!
            }
        }
        
        tmp = Array(repeating: 0.0, count: latencytime+1)
        //for i in 0..<tmp.count {
        //    tmp[i] = 0
        //} //ez már nem kell, a fordító gyorsabban inicializál
        if(e.asap<=e.alap){ //patch, majd meg kell nézni
            
            
            for i in e.asap...e.alap {
                for j in 0..<e.latency {
                    tmp[i+j] += wgt
                }
                if USE_TI != useWhichTime {
                    var maxIdx: Int!
                    let b = build_qi(e: e, t: i, wgt: wgt)
                    if tmp.count <= b.count {                                 // MARK:!!!
                        maxIdx = tmp.count
                    } else {
                        maxIdx = b.count
                    }
                    catlas_saxpby(Int32(maxIdx), Float(1), b, Int32(1), Float(1), &tmp, Int32(1))
                    
                    //addIp(a: &tmp, b: build_qi(e: e, t: i, wgt: wgt))
                }
            }
        }
        aFold(arr: &tmp)
        if !(e.transfers.isEmpty) {
            transferTimeInfo[e.id] = e.transfers
            usageCache[e.id] = tmp
        }
        return tmp
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    //!         Function buildC
    //!===================================================================================
    //!         Leírás: non-overlapped processor usage; caches result if required.
    //!
    //////////////////////////////////////////////////////////////////////////////////////
    
    private func buildC(c: inout [String : [Float]], max: inout Float, mean: inout Float, _sortedtype: [CNode]) {
        var u: [Float]
        var tot: [Float]
        var nodeTmp: CNode
        var type: [CNode] = _sortedtype
        var i: Int          = 0
        var test: Bool      = false
        
        
        
        /* for k in 1..<type.count { //kint rendezünk, nem itt mert ez nagyon lassú lesz
         for m in stride(from: type.count-1, through: k, by: -1) {
         if (type[m-1].type.compare(String(0)).rawValue) > 0 {
         nodeTmp = type[m-1]
         type[m-1] = type[m]
         type[m] = nodeTmp
         }
         }
         }*/
        
        tot = Array(repeating: 0.0, count: restartTime)
        
        repeat {
            if w[type[i].type] != 0 {
                max = 0
                
                for k in 0..<restartTime {
                    tot[k] = 0
                }
                repeat {
                    test = false
                    u = usageQm(e: type[i], wgt: Float(1)/Float(1 + type[i].alap - type[i].asap), useWhichTime: USE_QI)
                    for k in 0..<tot.count {
                        tot[k] += u[k]
                    }
                    if ((i != type.count-1) && (type[i].type == type[i+1].type)) {
                        test = true
                    }
                    i += 1
                } while ((i <= type.count) && (test==true))
                
                /* mean = 0
                 for k in 0..<tot.count {
                 mean += tot[k]
                 if tot[k] > max {
                 max = tot[k]
                 }
                 }
                 
                 mean = mean/Float(tot.count)
                 */
                for k in 0..<tot.count {
                    tot[k] = tot[k]//abs(tot[k]-mean)                   //difference from original force directed scheduler
                }
                if i <= type.count {
                    i -= 1
                    c[type[i].type] = tot
                }
                i += 1
            }
            else {
                i += 1
            }
        } while i < type.count
    }
    
    //////////////////////////////////////////////////////////////////////////////////////
    //!         Function setAsap
    //!===================================================================================
    //!         Leírás: set elops' ASAP times and set/update successors recursively
    //!
    //////////////////////////////////////////////////////////////////////////////////////
    
    private func setAsap(elops: [Int], now: Int) {
        for i in 0..<elops.count {
            if (ops[elops[i]].asap < now) {
                ops[elops[i]].asap = now
                setAsap(elops: ops[elops[i]].nxt, now: now + ops[elops[i]].latency)
            }
        }
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    //!         Function setAlap
    //!===================================================================================
    //!         Leírás: set elops' ALAP times and update predecessors recursively
    //!
    //////////////////////////////////////////////////////////////////////////////////////
    
    private func setAlap(elops: [Int], now: Int) {
        for i in 0..<elops.count {
            if (ops[elops[i]].alap > now-ops[elops[i]].latency) {
                ops[elops[i]].alap = (now - ops[elops[i]].latency)
                setAlap(elops: ops[elops[i]].prd, now: now-ops[elops[i]].latency)
            }
        }
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    //!         Function saveAsap
    //!===================================================================================
    //!         Leírás: save initial ASAP times
    //!
    //////////////////////////////////////////////////////////////////////////////////////
    
    private func saveAsap(e: CNode) {
        let locae = e
        
        for i in 0..<locae.nxt.count {
            ops[locae.nxt[i]].origAsap = ops[locae.nxt[i]].asap
            if !(ops[locae.nxt[i]].nxt.isEmpty) {
                saveAsap(e: ops[locae.nxt[i]])
            }
        }
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    //!         Function saveAlap
    //!===================================================================================
    //!         Leírás: save initial ALAP times
    //!
    //////////////////////////////////////////////////////////////////////////////////////
    var rec: Int = 0
    private func saveAlap(e: CNode) {
        let loce = e
        
        for i in 0..<loce.prd.count {
            ops[loce.prd[i]].origAlap = ops[loce.prd[i]].alap
            if !(ops[loce.prd[i]].prd.isEmpty) {
                saveAlap(e: ops[loce.prd[i]])
                rec += 1
            }
        }
        //  print("\(rec). rekurzív hurok.")
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    //!         Function restoreAsap
    //!===================================================================================
    //!         Leírás: restore saved ASAP times
    //!
    //////////////////////////////////////////////////////////////////////////////////////
    
    private func restoreAsap(e: CNode) {
        for i in 0..<e.nxt.count {
            ops[e.nxt[i]].asap = ops[e.nxt[i]].origAsap
            if !(ops[e.nxt[i]].nxt.isEmpty) {
                restoreAsap(e: ops[e.nxt[i]])
            }
        }
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    //!         Function restoreAlap
    //!===================================================================================
    //!         Leírás: restore saved ALAP times
    //!
    //////////////////////////////////////////////////////////////////////////////////////
    
    private func restoreAlap(e: CNode) {
        for i in 0..<e.prd.count {
            ops[e.prd[i]].alap = ops[e.prd[i]].origAlap
            if !(ops[e.prd[i]].prd.isEmpty) {
                restoreAlap(e: ops[e.prd[i]])
            }
        }
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    //!         Function aadd
    //!===================================================================================
    //!         Leírás: add arrays (by reference)
    //!
    //////////////////////////////////////////////////////////////////////////////////////
    
    private func aadd(a: [Float], b: [Float], wgt: Int = 1) -> [Float] {
        var tmp: [Float] = a
        var maxIdx: Int!
        if a.count <= b.count {                                 // MARK:!!!
            maxIdx = a.count
        } else {
            maxIdx = b.count
        }
        if wgt == 1 {
            for i in 0..<maxIdx {
                tmp[i] += b[i]
            }
        } else {
            for i in 0..<maxIdx {
                tmp[i] += Float(wgt)*b[i]
            }
        }
        return tmp
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    //!         Function amul
    //!===================================================================================
    //!         Leírás: scalar multiply arrays (by reference)
    //!
    //////////////////////////////////////////////////////////////////////////////////////
    
    private func amul(a: [Float], b: [Float]) -> Float {
        var tmp: Float = 0
        
        for i in 0..<a.count {
            tmp += a[i]*b[i]
        }
        return tmp
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    //!         Function cdc
    //!===================================================================================
    //!         Leírás: calculates C * deltaC product from arefs
    //!
    //////////////////////////////////////////////////////////////////////////////////////
    // MARK: - TODO
    private func cdc(c: inout [String : [Float]], newC: inout [String : [Float]], fce: inout Float) {
        var tmp         = [Float]()
        let pIterNewC = newC.startIndex
        var i: Int = 0
        for (key, value) in c {
            if key != String(0) {
                var newErt = (key: "", value: [Float(0.0), Float(0.0)])
                newErt = newC[newC.index(pIterNewC, offsetBy: i)]
                
                var maxIdx: Int!
                if newErt.value.count <= value.count {                                 // MARK:!!!
                    maxIdx = newErt.value.count
                } else {
                    maxIdx = value.count
                }
                
                tmp = value
                
                catlas_saxpby(Int32(maxIdx), Float(1), newErt.value, Int32(1), Float(1), &tmp, Int32(1))
                
                //tmp =    aadd(a: newErt.value, b: value)
                //fce += (Float(w[key]!)*amul(a: value, b: tmp))
                
                fce += (Float(w[key]!))*cblas_sdot(Int32(value.count), value, Int32(1), tmp, Int32(1))
            }
            i += 1
        }
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    //!         Function updateBestTime
    //!===================================================================================
    //!         Leírás: set new best point; called if force is optimal
    //!
    //////////////////////////////////////////////////////////////////////////////////////
    // MARK: - Referenciával kell meghívni!!!
    private func updateBestTime(fce: Float, bestFce: Float, t: Int, bestTimes: inout [Int]) -> [Int] {
        if fce >= bestFce{
            print("update_best_time() should not be called now")
        }
        if abs(fce-bestFce) > (EPS) {
            bestTimes.removeAll()
        }
        bestTimes.append(t)
        return bestTimes
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    //!         Function dumpelop
    //!===================================================================================
    //!         Leírás:
    //!
    //////////////////////////////////////////////////////////////////////////////////////
    //MARK: - TODO Eredmény visszadása, kiírása
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    //!         Function genOrder
    //!===================================================================================
    //!         Leírás: find scheduling order (defaults to enumeration)
    //!
    //////////////////////////////////////////////////////////////////////////////////////
    
    private func genOrder(ord: [CNode], p: Bool) -> [CNode] {
        var _ord: [CNode] = ord
        var testArg = -1
        if p == true {
            testArg = 0
        }
        if testArg == -1 {
            var i: Int = 0
            while (i<ord.count) {
                if(ord[i].type == "Buffer") {
                    _ord.remove(at: i+1)                             // MARK:!!!??
                    i -= 1
                }
                i += 1
            }
            w["Buffer"] = 0
            testArg = -1
        }
        return _ord
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    //!         Function forcedir
    //!===================================================================================
    //!         Leírás: Gondolom majd itt kell módosítgatni
    //!
    //////////////////////////////////////////////////////////////////////////////////////
    
    private func forcedir(delayties: Bool, fixed: inout Int, tofix: inout Int, ord: [CNode], spect: Bool = true) -> [CNode] {           // argv-k nincsenek átadve, egyelőre nem biztos, hogy most kell
        var e: CNode
        var nodeTmp: CNode
        
        var delayed             = [CNode]()
        var list                = [CNode]()
        
        var bestTimes           = [Int]()
        var meanChange          = [Float]()
        var forceChange         = [Float]()
        var maxChange           = [Float]()
        
        
        
        var c                   = [String : [Float]]()
        var newC                = [String : [Float]]()
        
        var fce: Float          = 0
        var mean: Float         = 0
        var bestFce: Float      = PLUS_INF_FCE
        var max: Float          = 0 //MARK: -!!! Értékadás nem feltétlenül van rendben
        
        var bestIndex: Int      = 0 //si arg 's' ?
        var ts: Int
        var tl: Int
        var testArg: Int        = -1
        
        delayed.removeAll()
        forceChange.removeAll()
        print("## \(fixed)/\(tofix) done.")
        Log?.Print(log: "## \(fixed)/\(tofix) done.", detailed: .Normal)
        list = ord
        var sortedops = ops.sorted(by: { $0.type > $1.type })
        while list.count != 0 {
            // sort list, descending order operations by mobility (difference) or by latency if difference = 0
            for i in 1..<list.count {
                for j in stride(from: list.count-1, through: i, by: -1) {
                    if ((list[j-1].alap - list[j-1].asap) > (list[j].alap - list[j].asap)) {
                        nodeTmp = list[j-1]
                        list[j-1] = list[j]
                        list[j] = nodeTmp
                    }
                    else if ((list[j-1].alap - list[j-1].asap) == (list[j].alap - list[j].asap)) {
                        if (list[j-1].latency > list[j].latency) {
                            nodeTmp = list[j-1]
                            list[j-1] = list[j]
                            list[j] = nodeTmp
                        }
                    }
                    else {
                        
                    }
                }
            }
            
            e = ops[list[0].id]
            for i in 1..<list.count {
                list[i-1] = list[i]
            }
            //let listSize = list.count
            list.removeLast()                           // MARK:!!!
            if e.asap == e.alap {
                fixed += 1
                print("## skipping node \(e.id!).\n## \(fixed)/\(tofix) done.")
                Log?.Print(log: "## \(fixed)/\(tofix) done.", detailed: .Normal)
                forceChange.append(0)
            }
            else {
                bestTimes.removeAll()
                bestFce = PLUS_INF_FCE
                
                print("## testing node \(e.id!)(\(e.asap) to \(e.alap)")
                
                saveAsap(e: e)
                saveAlap(e: e)
                
                genTransfers()
                
                buildC(c: &c, max: &max, mean: &mean, _sortedtype: sortedops)       // a max nincs inicializálva!! de nem is kell az ops viszont rendezve kell
                
                maxChange.append(max)
                meanChange.append(mean)
                
                ts = e.asap
                tl = e.alap
                bestTimes.append(ts)
                
                for i in ts...tl {
                    fce = 0
                    bestIndex = 0
                    
                    // ops[e.id].asap = i
                    // ops[e.id].alap = i
                    e.asap = i
                    e.alap = i
                    
                    setAsap(elops: e.nxt, now: i+e.latency)
                    setAlap(elops: e.prd, now: i)
                    
                    genTransfers()                  // Update q(i) configuration
                    
                    buildC(c: &newC, max: &max, mean: &mean, _sortedtype: sortedops)
                    
                    
                    
                    
                    //MARK: -XXXXXXXXXXXXXXIttkellkiegészíteniXXXXXXXXXXXXX
                    cdc(c: &c, newC: &newC, fce: &fce)          // calculate force
                    
                    if spect
                    {
                        let sajatspect = spektrum.Spectrum[spektrum.NodeIDCoder.index(of: e.id!)!]
                        let sajatgroup = spektrum.Group[spektrum.NodeIDCoder.index(of: e.id!)!]
                        
                        for k in 0..<ops.count{
                            if e.id != ops[k].id{
                                
                                
                                let kspect = spektrum.Spectrum[spektrum.NodeIDCoder.index(of: ops[k].id!)!]
                                let kgroup = spektrum.Group[spektrum.NodeIDCoder.index(of: ops[k].id!)!]
                                if (kgroup == sajatgroup)
                                {
                                    for j in e.asap...(e.asap+e.latency){
                                        
                                        if ((ops[k].asap == ops[k].alap) && (ops[k].asap<=j) && (ops[k].asap+ops[k].latency>=j)){
                                            
                                            fce = fce + fce * Float(1 / (kspect-sajatspect) / (kspect-sajatspect))
                                            
                                        }
                                        
                                    }
                                }
                            }
                            
                        }
                    }
                    
                    if (argV) {
                        print("## F : \(fce)        # node\(e.id!)           \(i)")
                    }
                    if fce < (bestFce) {
                        updateBestTime(fce: fce, bestFce: bestFce, t: i, bestTimes: &bestTimes)
                        bestFce = fce
                    }
                    restoreAsap(e: e)
                    restoreAlap(e: e)
                }
                
                if (delayties && (bestTimes.count >= 2) && ((tofix-fixed) > 1)) {
                    print("## tie node \(e.id!) delayed")
                    delayed.append(e)
                }
                else {
                    if (delayties && (bestTimes.count >= 2) && ((tofix-fixed) == 1)) {
                        print("## no use delaying node \(e.id!) even if tied")
                        for i in 0..<delayed.count {
                            print("node \(delayed[i].id!) ,")
                        }
                    }
                    print("## node \(e.id!) best in cycles \(bestTimes[bestIndex])")
                    
                    forceChange.append(bestFce)
                    
                    ops[e.id].asap = bestTimes[bestIndex]
                    ops[e.id].alap = bestTimes[bestIndex]
                    e.asap = bestTimes[bestIndex]
                    e.alap = bestTimes[bestIndex]
                    
                    setAsap(elops: e.nxt, now: (e.asap + e.latency))
                    setAlap(elops: e.prd, now: e.alap)
                    
                    fixed += 1
                }
                print("##   \(fixed)/\(tofix) done")
                Log?.Print(log: "## \(fixed)/\(tofix) done.", detailed: .Normal)
            }
            c.removeAll()
            newC.removeAll()
        }
        if delayed.count == 0 {
            // Kiírás fájlba, vagy.. ugye nem oda.....
        }
        //if argV {
        
        
        print("## force changes were ")
        for i in 0..<forceChange.count {
            print("\(forceChange[i]),")
        }
        print("## mean of used processors by steps ")
        for i in 0..<meanChange.count {
            print("\(meanChange[i]),")
        }
        print("## max of used processors by steps ")
        for i in 0..<maxChange.count {
            print("\(maxChange[i]),")
            //     }
        }
        print("## processors used by steps ")
        for i in 0..<latencytime
        {
            cpuusage.append(0)
            for j in 0..<ops.count
            {
                if ((ops[j].asap <= i) && (ops[j].asap+ops[j].latency >= i))
                {
                    cpuusage[i]=cpuusage[i]+1
                }
            }
            print("\(cpuusage[i]),")
            if (cpuusage[i] > maxusage)
            {
                maxusage = cpuusage[i]
            }
        }
        
        return delayed
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    //!         Function genwgt
    //!===================================================================================
    //!         Leírás: set undefined weights to 1
    //!         Ez szerintem egyáltalán nem működik....
    //////////////////////////////////////////////////////////////////////////////////////
    
    private func genwgt(type: inout [CNode]) {
        var i: Int = 0
        var tmp = [String: Int]()
        repeat {
            if w.index(forKey: type[i].type) == nil {
                w.updateValue(1, forKey: type[i].type)
            }
            i += 1
        } while i < type.count
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    //!         Function writeBack
    //!===================================================================================
    //!         Leírás: visszaadja a csoportokba a startTimeokat
    //!
    //////////////////////////////////////////////////////////////////////////////////////
    
    func writeBack() {
        for i in 0..<ops.count {
            let indexPath = ops[i].groupPath
            (groups[indexPath![0]].children[indexPath![1]] as! Node).startTime = ops[i].asap
        }
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    //!         Function main
    //!===================================================================================
    //!         Leírás: find scheduling order (defaults to enumeration)
    //! Arguments:
    //! p :  include buffers in allocation estimation
    //! s :  choose first best-force cycle in case of a tie        ??????
    //! d :  delay scheduling operations with optimum ties
    //! v :  increase detail level in output
    //////////////////////////////////////////////////////////////////////////////////////
    
    func mainAlgorithm(p: Bool, s: Bool, d: Bool, v: Bool, spect: Bool = true) {
        var ord         = [CNode]()
        var delayed     = [CNode]()
        
        var testArg: Int        = -1
        var tofix: Int          = 0
        var fixed: Int          = 0
        var roundstone: Int     = 1
        
        argV = v
        
        // readInput()          Itt kell a bemenetet beadni
        
        findL()
        
        if restartTime == -1 {
            restartTime = l
        }
        
        ord = genOrder(ord: ops, p: p)
        genwgt(type: &ops)
        
        print("## scheduling...")
        
        tofix = ord.count
        
        if d {
            testArg = 0
            
            delayed = forcedir(delayties: true, fixed: &fixed, tofix: &tofix, ord: ord, spect: spect)
            
            while ((delayed.count > 0) && (roundstone < maxdelayrounds)) {
                print("## resolving ties (round \(roundstone)")
                delayed = forcedir(delayties: true, fixed: &fixed, tofix: &tofix, ord: ord)
                roundstone += 1                 // Schedule in second round
            }
            
            if delayed.count < 0 {
                print("## unresolved ties after \(roundstone) rounds")
                for i in 0..<delayed.count {
                    print("node \(delayed[i].id),")
                }
            }
        }
        else {
            forcedir(delayties: false, fixed: &fixed, tofix: &tofix, ord: ord, spect: spect)
        }
        testArg = -1
        return
    }
    
    func pushMatrix(groups: [GraphElement]) -> (matrix: [Double], sizeOfmatrix: Int, weight: [Int]) {
        
        var weight: [Int] = []
        var sizeOfMatrix : Int = 0
        for i in 0..<groups.count {             // Összeszámolja az összes pontot a gráfban
            sizeOfMatrix += groups[i].children.count
        }
        var Matrix: [Double] = Array(repeating: 0.0, count: sizeOfMatrix*sizeOfMatrix)
        Matrix.removeAll()
        for i in 0..<sizeOfMatrix*sizeOfMatrix {
            Matrix.append(0)
        }
        
        
        for i in 0..<groups.count {
            for j in 0..<groups[i].children.count {
                let currentWeight = (groups[i].children[j] as! Node).weight
                if currentWeight > 1 {
                    weight.append(currentWeight)
                } else {
                    weight.append(1)
                }
                for k in 0..<groups[i].children[j].children.count {
                    let parent1 = (groups[i].children[j].children[k] as! Edge).parentsNode
                    let parent2 = (groups[i].children[j].children[k] as! Edge).parentdNode
                    
                    
                    Matrix[parent2.nodeID*sizeOfMatrix + parent1.nodeID] = (-1*(Double((groups[i].children[j].children[k] as! Edge).weight)))
                    Matrix[parent1.nodeID*sizeOfMatrix + parent2.nodeID] = (-1*(Double((groups[i].children[j].children[k] as! Edge).weight)))
                    
                    // Mi van, ha két pont között több él is van?
                }
            }
        }
        
        
        
        for j in 0..<sizeOfMatrix {
            var rowSum : Double = 0
            for i in (j*sizeOfMatrix)..<((j+1)*sizeOfMatrix) {
                rowSum = rowSum + Matrix[i]
            }
            Matrix[j+(j*sizeOfMatrix)] = (-1)*rowSum
        }
        
        for i in 0..<sizeOfMatrix {
            for j in 0..<sizeOfMatrix {
                print("\(Matrix[i*sizeOfMatrix+j]), ",terminator:"")
            }
            print("\n")
        }
        
        return (Matrix, sizeOfMatrix, weight)
    }
    
    func DoProcess(schedule: SchedulingElement, p: Bool, s: Bool, d: Bool, spect: Bool = true) ->  ScheduleResults {
        self.restartTime = schedule.restartTime
        self.latencytime = schedule.latency
        if self.restartTime > self.latencytime
        {
            self.restartTime = self.latencytime
        }
        
        if spektrum == nil
        {
            let matrixStruct = pushMatrix(groups: groups)
            
            
            let WNCutsched: WNCut = WNCut(sizeOfMatrix: matrixStruct.sizeOfmatrix, sourceMatrix: matrixStruct.matrix)
            
            spektrum = WNCutsched.WNCut(weight: matrixStruct.weight)
        }
        
        
        readInput()
        calculateAsapAlap(latencyTime: schedule.latency)
        mainAlgorithm(p: p, s: s, d: d, v: VERBOSE, spect: spect)
        writeBack()
        
        let res = ScheduleResults(name: schedule.name, graph: groups, processorUsage: cpuusage, latency: latencytime, restartTime: restartTime, allGroupsIndex: 0xFFFF)
        
        
        return res
    }
    /*
     func RLScan(restartTimefrom: Int, latencyTimefrom: Int, restartTimeto: Int, latencyTimeto: Int,restartTimesteps: Int, latencyTimesteps: Int , spect: Bool = true) -> ([[Int]]) {
     
     let stepcountr = (restartTimeto - restartTimefrom)/restartTimesteps
     let stepcountl = (latencyTimeto - latencyTimefrom)/latencyTimesteps
     var ered: [[Int]] = Array(repeating: Array(repeating: 0, count: stepcountr), count: stepcountl)
     
     
     
     for i in 0..<stepcountr{
     DispatchQueue.concurrentPerform(iterations: stepcountl) {
     
     let j = $0
     let iter: SpectralForceDirected = SpectralForceDirected(groups: self.groups)
     let retvar = iter.DoProcess(restartTime: restartTimefrom+i*restartTimesteps, latencyTime: latencyTimefrom+j*latencyTimesteps, p: false, s: false, d: false)
     
     
     
     ered[i][j] = retvar.proccount!
     }
     
     }
     
     
     return ered
     
     }
     */
    
    func RLScan(schedules: [SchedulingElement], p: Bool, s: Bool, d: Bool, spect: Bool = true) -> ([ScheduleResults]) {
        
        
        var ered: [ScheduleResults] = Array(repeatElement(ScheduleResults(name: "", graph: [], processorUsage: [0], latency: 0, restartTime: 0, allGroupsIndex: 0xFFFF) , count: schedules.count))
        
        if spect == true
        {
            let matrixStruct = pushMatrix(groups: groups)
            
            
            let WNCutsched: WNCut = WNCut(sizeOfMatrix: matrixStruct.sizeOfmatrix, sourceMatrix: matrixStruct.matrix)
            
            spektrum = WNCutsched.WNCut(weight: matrixStruct.weight)
        }
        
        DispatchQueue.concurrentPerform(iterations: schedules.count) {
            
            let j = $0
            let iter: SpectralForceDirected = SpectralForceDirected(groups: self.groups)
            if spect == true
            {
                iter.spektrum = spektrum
            }
            else {
                iter.spektrum = nil
            }
            let retvar = iter.DoProcess(schedule: schedules[j], p: false, s: false, d: false, spect: spect)
            
            
            ered[j] = retvar
        }
        
        
        
        
        return ered
        
    }
    
}

