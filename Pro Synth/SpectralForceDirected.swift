//
//  SpectralForceDirected.swift
//  Pro Synth
//
//  Created by Markovits Gergő on 2017. 11. 08..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//

import Cocoa

let EPS: Float      = 0.05
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
    
    var transferTimeInfo                    = [Int : [Int]]()
    var usageCache                          = [Int : [Float]]()
    var w                                   = [String : Int]()
    
    // CNode osztály példányosítása
    var ops                                 = [CNode]()
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    //!         Function readInput
    //!===================================================================================
    //!         Leírás: Adatok betöltése a gráfszerkezetből
    //!         TODO
    //////////////////////////////////////////////////////////////////////////////////////
    
    func readInput() {
        var tmpNode: CNode
        for i in 0..<groups.count {
            for j in 0..<groups[i].children.count {
                let id = (groups[i].children[j] as! Node).nodeID
                let weight = (groups[i].children[j] as! Node).weight
                let name = groups[i].children[j].name
                let output = (groups[i].children[j] as! Node).output
                tmpNode = CNode(NodeID: id, Name: name, Weight: weight, Output: output)
                ops.append(tmpNode)
            }
        }
        for i in 0..<groups.count {
            for j in 0..<groups[i].children.count {
                for k in 0..<groups[i].children[j].children.count {
                    let sNode = (groups[i].children[j].children[k] as! Edge).parentsNode.nodeID
                    let dNode = (groups[i].children[j].children[k] as! Edge).parentdNode.nodeID
                    ops[sNode].nxt.append(dNode)
                }
            }
        }
        for i in 0..<ops.count {
            if !ops[i].output {
                for j in 0..<ops[i].nxt.count {
                    ops[ops[i].nxt[j]].prd.append(i)
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
            if ((ops[i].alap + ops[i].latency) > 1) {
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
            tmp = Array(repeating: 0.0, count: restartTime)     // MARK:!!!
            for j in 0..<tmp.count {
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
        
        follow = Array(repeating: 0.0, count: l)                // MARK:!!!
        for i in 0..<e.nxt.count {
            nextAsap = t + e.latency
            if follow[nextAsap] < wgt {
                follow[nextAsap] = wgt
            }
            if ((ops[e.nxt[i]].type != "Buffer") && (nextAsap >= ops[e.nxt[i]].asap)) {
                plusWgt = wgt / (Float(1) + Float(ops[e.nxt[i]].alap) - Float(ops[e.nxt[i]].asap))
                for j in 2..<ops[e.nxt[i]].latency {
                    if follow[j + nextAsap-1] < plusWgt {
                        follow[j + nextAsap-1] = plusWgt
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
        if transferTimeInfo.index(forKey: e.id) != transferTimeInfo.endIndex {          // MARK:!!! Itt mi a fenét akart az eredeti szerző???
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
        tmp.removeAll()
        tmp.append(0)
        for i in 0..<tmp.count {
            tmp[i] = 0
        }
        for i in e.asap...e.alap {
            for j in 0..<e.latency {
                tmp[i+j] += wgt
            }
            if USE_TI != useWhichTime {
                addIp(a: &tmp, b: build_qi(e: e, t: i, wgt: wgt))
            }
        }
        aFold(arr: &tmp)
        if !(e.transfers.isEmpty) {
            transferTimeInfo[e.id] = e.transfers
        }
        return tmp
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    //!         Function buildC
    //!===================================================================================
    //!         Leírás: non-overlapped processor usage; caches result if required.
    //!
    //////////////////////////////////////////////////////////////////////////////////////
   
    private func buildC(c: inout [String : [Float]], max: inout Float, mean: inout Float, _type: [CNode]) {
        var u: [Float]
        var tot: [Float]
        var nodeTmp: CNode
        var type: [CNode] = _type
        var i: Int          = 0
        var test: Bool      = false
        
        for k in 1..<type.count {
            for m in stride(from: type.count-1, through: k, by: -1) {
                if (type[m-1].type.compare(String(0)).rawValue) > 0 {
                    nodeTmp = type[m-1]
                    type[m-1] = type[m]
                    type[m] = nodeTmp
                }
            }
        }
        
        repeat {
            if w[type[i].type] != 0 {
                max = 0
                tot = Array(repeating: 0.0, count: restartTime)                // MARK:!!!
                for k in 0..<tot.count {
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
                
                mean = 0
                for k in 0..<tot.count {
                    mean += tot[k]
                    if tot[k] > max {
                        max = tot[k]
                    }
                }
                
                mean = mean/Float(tot.count)
                
                for k in 0..<tot.count {
                    tot[k] = abs(tot[k]-mean)                   //difference from original force directed scheduler
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
                ops[elops[i]].alap = now
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
        for i in 0..<e.nxt.count {
            ops[e.nxt[i]].origAsap = ops[e.nxt[i]].asap
            if !(ops[e.nxt[i]].nxt.isEmpty) {
                saveAsap(e: ops[e.nxt[i]])
            }
        }
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    //!         Function saveAlap
    //!===================================================================================
    //!         Leírás: save initial ALAP times
    //!
    //////////////////////////////////////////////////////////////////////////////////////
    
    private func saveAlap(e: CNode) {
        for i in 0..<e.prd.count {
            ops[e.prd[i]].origAlap = ops[e.prd[i]].alap
            if !(ops[e.prd[i]].prd.isEmpty) {
                saveAlap(e: ops[e.prd[i]])
            }
        }
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
                tmp = aadd(a: newErt.value, b: value)
                fce += (Float(w[key]!)*amul(a: value, b: tmp))
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
        if fce >= bestFce + EPS {
            print("update_best_time() should not be called now")
        }
        if abs(fce-bestFce) > EPS {
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

    private func forcedir(delayties: Bool, fixed: inout Int, tofix: inout Int, ord: [CNode]) -> [CNode] {           // argv-k nincsenek átadve, egyelőre nem biztos, hogy most kell
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
        list = ord
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
                print("## skipping node \(e.id).\n## \(fixed)/\(tofix) done.")
                forceChange.append(0)
            }
            else {
                bestTimes.removeAll()
                bestFce = PLUS_INF_FCE
                print("## testing node \(e.id)(\(e.asap) to \(e.alap)")
                
                saveAsap(e: e)
                saveAlap(e: e)
                
                genTransfers()
                
                buildC(c: &c, max: &max, mean: &mean, _type: ops)       // a max nincs inicializálva!!
                
                maxChange.append(max)
                meanChange.append(mean)
                
                ts = e.asap
                tl = e.alap
                
                for i in ts...tl {
                    fce = 0
                    
                    ops[e.id].asap = i
                    ops[e.id].alap = i
                    e.asap = i
                    e.alap = i
                    
                    setAsap(elops: e.nxt, now: i+e.latency)
                    setAlap(elops: e.prd, now: i)
                    
                    genTransfers()                  // Update q(i) configuration
                    
                    buildC(c: &newC, max: &max, mean: &mean, _type: ops)
                    
                    //MARK: -XXXXXXXXXXXXXXIttkellkiegészíteniXXXXXXXXXXXXX
                    cdc(c: &c, newC: &newC, fce: &fce)          // calculate force
                    if (argV) {
                        print("## F : \(fce)        # node\(e.id)           \(i)")
                    }
                    if fce < (bestFce+EPS) {
                        updateBestTime(fce: fce, bestFce: bestFce, t: i, bestTimes: &bestTimes)
                        bestFce = fce
                    }
                    restoreAsap(e: e)
                    restoreAlap(e: e)
                }
                
                if (delayties && (bestTimes.count >= 2) && ((tofix-fixed) > 1)) {
                    print("## tie node \(e.id) delayed")
                    delayed.append(e)
                }
                else {
                    if (delayties && (bestTimes.count >= 2) && ((tofix-fixed) == 1)) {
                        print("## no use delaying node \(e.id) even if tied")
                        for i in 0..<delayed.count {
                            print("node \(delayed[i].id) ,")
                        }
                    }
                    print("## node \(e.id) best in cycles \(bestTimes[bestIndex])")
                    
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
            }
            c.removeAll()
            newC.removeAll()
        }
        if delayed.count == 0 {
            // Kiírás fájlba, vagy.. ugye nem oda.....
        }
        if argV {
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
            if w.index(forKey: type[i].type) == w.endIndex {
                w.updateValue(1, forKey: type[i].type)
            }
            i += 1
        } while i < type.count
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

    func mainAlgorithm(p: Bool, s: Bool, d: Bool, v: Bool) {
        var ord         = [CNode]()
        var delayed     = [CNode]()
        
        var testArg: Int        = -1
        var tofix: Int          = 0
        var fixed: Int          = 0
        var roundstone: Int     = 1
        
        argV = v
        
        // readInput()          Itt kell a bemenetet beadni
        
        if restartTime == -1 {
            restartTime = l
        }
        
        print("## scheduling...")
        
        tofix = ord.count
        
        if d {
            testArg = 0
            
            delayed = forcedir(delayties: true, fixed: &fixed, tofix: &tofix, ord: ord)
            
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
            forcedir(delayties: false, fixed: &tofix, tofix: &fixed, ord: ord)
        }
        testArg = -1
        return
    }
    
    func DoProcess(restartTime: Int, p: Bool, s: Bool, d: Bool) {
        self.restartTime = restartTime
        readInput()
        mainAlgorithm(p: p, s: s, d: d, v: VERBOSE)
    }
}
