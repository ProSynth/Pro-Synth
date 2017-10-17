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

    
    /* A Laplace Mátrix generáló */
    // Bemenet: Diag vektor, D-W mátrix és a mátrixok mérete
    // Kimenet: A Laplapce mátrix
    func makeLaplace(matrix: [Double], sizeOfMatrix: Int) -> [Double] {
        // Változók definiálása
        let sizeOfMatrixInt32 : Int32 = Int32(sizeOfMatrix)
        var Matrix: [Double] = matrix
        var DiagVector = [Double](repeatElement(0x00, count: sizeOfMatrix))
        var DiagMatrix = [Double](repeatElement(0x00, count: (sizeOfMatrix*sizeOfMatrix)))
        var L1Matrix = [Double](repeatElement(0x00, count: (sizeOfMatrix*sizeOfMatrix)))
        var LaplaceMatrix = [Double](repeatElement(0x00, count: (sizeOfMatrix*sizeOfMatrix)))
        
        var Diag = [Double](repeatElement(0x00, count: sizeOfMatrix))
        for i in 0..<sizeOfMatrix {                 // Diagonális Mátrix készítése
            for j in 0..<sizeOfMatrix {
                if i == j {
                    Diag[i] = Matrix[i*sizeOfMatrix+j]
                }
            }
        }
        
        for i in 0..<sizeOfMatrix {
            DiagVector[i] = sqrt(Diag[i])       // Gyökvonás elemenként
        }
        for i in 0..<sizeOfMatrix {
            DiagVector[i] = 1/DiagVector[i]       // A vektor invertálása
        }
        
        for i in 0..<sizeOfMatrix {                 // Diagonális Mátrix készítése
            for j in 0..<sizeOfMatrix {
                if i == j {
                    DiagMatrix[(i*sizeOfMatrix)+j] = DiagVector[i]
                }
            }
        }
        // D*(D-W)*D'
        cblas_dgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans, sizeOfMatrixInt32, sizeOfMatrixInt32, sizeOfMatrixInt32, 1, &DiagMatrix, 1, &Matrix, 1, 0, &L1Matrix, 1)     // D*(D-W)
        cblas_dgemm(CblasRowMajor, CblasNoTrans, CblasTrans, sizeOfMatrixInt32, sizeOfMatrixInt32, sizeOfMatrixInt32, 1, &L1Matrix, 1, &DiagMatrix, 1, 0, &LaplaceMatrix, 1)      // (D*(D-W))*D' (D transzponálva!! bár nincs értelme)
        
        return LaplaceMatrix
    }
    
    
    
}
