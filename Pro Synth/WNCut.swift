//
//  WNCut.swift
//  Pro Synth
//
//  Created by Pro Synth on 2017. 10. 12..
//  Copyright © 2017. Gergo Markovits. All rights reserved.
//


import Cocoa
import Accelerate
import simd

class WNCut: NSObject {

    let MAX : Int = Int(sqrt(Double(Matrix.count)))
    
    func lanczos() {
        
        var v = [Double] ()
        v.removeAll()
        for i in 0..<MAX {
            v.append(Double(arc4random()))
        }
        
        var w1 = [Double] ()
        w1.removeAll()
        for i in 0..<MAX {
            w1.append(1)
        }
        
        cblas_dgemv(CblasRowMajor, CblasNoTrans, Int32(MAX), Int32(MAX), 1, &Matrix, Int32(MAX), &v, 1, 0, &w1, 1)
        var a1 : Double
        a1 = cblas_ddot(Int32(MAX), &w1, 1, &v, 1)
        catlas_daxpby(Int32(MAX), -(a1), &v, 1, 1, &w1, 1)
        var tmpv = [Double](repeatElement(0.0, count: MAX))
        var prevv = [Double](repeatElement(0.0, count: MAX))
        prevv = v
        for j in 1..<MAX {
            let Bj : Double = cblas_dnrm2(Int32(MAX), &w1, 1)
            if Bj != 0 {
                tmpv = w1.map({$0 * (1/Bj)})
                cblas_dgemv(CblasRowMajor, CblasNoTrans, Int32(MAX), Int32(MAX), 1, &Matrix, Int32(MAX), &tmpv, 1, 0, &currw, 1)
                a1 = cblas_ddot(Int32(MAX), &currw, 1, &tmpv, 1)
                //w1 = tmp
                
                catlas_daxpby(Int32(MAX), a1, &tmpv, 1, Bj, &prevv, 1)   // Itt még a változókat rendbe kell rakni
                catlas_daxpby(Int32(MAX), -1, &tmpv, 1, 1, &currw, 1)
                w1 = currw
                prevv = tmpv
                print("\(j)-edik számolás")
            } else {
                
                
            }
            
        }
    }
    
}
