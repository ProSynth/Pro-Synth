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

// Arguments:
// p :  include buffers in allocation estimation
// s :  choose first best-force cycle in case of a tie        ??????
// d :  delay scheduling operations with optimum ties
// v :  increase detail level in output

// Jelzések: //!!! --> Hiba lehetőség

class SpectralForceDirected: NSObject {
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
    
    // MARK: - Bemenet kezelés - ki kell találni
    
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    //!         Function findL
    //!===================================================================================
    //!         Leírás: ???
    //!
    //////////////////////////////////////////////////////////////////////////////////////
    
    func findL() {
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
    
    func genTransfers() {
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
    
    func aFold(arr: [Float]) -> [Float] {
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
    
    func build_qi(e: CNode, t: Int, wgt: Float) -> [Float] {
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
    
    func addIp(a: inout [Float], b: [Float], wgt: Int = 1) -> [Float] {
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
    // MARK: - TODO
    func usageQm(e: CNode, wgt: Float = 1, useWhichTime: Int = USE_QI) -> [Float] {
        var tmp             = [Float]()
        var test: Bool      = true
        if transferTimeInfo[e.id] != transferTimeInfo. {
            <#code#>
        }
        return tmp
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    //!         Function buildC
    //!===================================================================================
    //!         Leírás: non-overlapped processor usage; caches result if required.
    //!
    //////////////////////////////////////////////////////////////////////////////////////
    // MARK: - TODO
    
    //////////////////////////////////////////////////////////////////////////////////////
    //!         Function setAsap
    //!===================================================================================
    //!         Leírás: set elops' ASAP times and set/update successors recursively
    //!
    //////////////////////////////////////////////////////////////////////////////////////
    
    func setAsap(elops: [Int], now: Int) {
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
    
    func setAlap(elops: [Int], now: Int) {
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
    
    func saveAsap(e: CNode) {
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
    
    func saveAlap(e: CNode) {
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
    
    func restoreAsap(e: CNode) {
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
    
    func restoreAlap(e: CNode) {
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
    
    func aadd(a: [Float], b: [Float], wgt: Int = 1) -> [Float] {
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
    
    func amul(a: [Float], b: [Float]) -> Float {
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
    func cdc(<#parameters#>) {
        <#function body#>
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    //!         Function updateBestTime
    //!===================================================================================
    //!         Leírás: set new best point; called if force is optimal
    //!
    //////////////////////////////////////////////////////////////////////////////////////
    // MARK: - Referenciával kell meghívni!!!
    func updateBestTime(fce: Float, bestFce: Float, t: Int, bestTimes: inout [Int]) -> [Int] {
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
    //!         Function genOrder
    //!===================================================================================
    //!         Leírás: find scheduling order (defaults to enumeration)
    //!
    //////////////////////////////////////////////////////////////////////////////////////
    
    func genOrder(ord: [CNode], p: Bool) -> [CNode] {
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
    
    func forcedir(delayties: Bool, fixed: inout Int, tofix: inout Int, ord: [CNode]) -> [CNode] {           // argv-k nincsenek átadve, egyelőre nem biztos, hogy most kell
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
        var max: Float
        
        var bestIndex: Int       // =-1 si arg 's' ?
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
                
                // MARK: -TODO
            }
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

    func mainAlgorithm(p: Bool, s: Bool, d: Bool, v: Bool) {
        
    }
}
