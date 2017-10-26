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

var eigVectorArray: [[Double]] = []
var eigValueArray: [Double] = []

var minEigVector: [Double] = []
var minEigValue: Double!

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
        cblas_dgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans, sizeOfMatrixInt32, sizeOfMatrixInt32, sizeOfMatrixInt32, 1, &DiagMatrix, sizeOfMatrixInt32, &Matrix, sizeOfMatrixInt32, 0, &L1Matrix, sizeOfMatrixInt32)     // D*(D-W)
        cblas_dgemm(CblasRowMajor, CblasNoTrans, CblasTrans, sizeOfMatrixInt32, sizeOfMatrixInt32, sizeOfMatrixInt32, 1, &L1Matrix, sizeOfMatrixInt32, &DiagMatrix, sizeOfMatrixInt32, 0, &LaplaceMatrix, sizeOfMatrixInt32)      // (D*(D-W))*D' (D transzponálva!! bár nincs értelme)
        
        for i in 0..<(sizeOfMatrix*sizeOfMatrix) {
            if LaplaceMatrix[i].isNaN {
                print("Nem szám is van benne")
            }
        }
        
        return LaplaceMatrix
    }

    
    
    
    
    /* A Lánczos algoritmus egyetlen sajátvektorra */
    // Bemenet: A számolni kívánt mátrix, és mérete
    // Kimenet: A sajátvektor és a sajátérték
    func Lanczos2(sMatrix : [Double], sizeOfMatrix: Int, initVector: [Double], forcedTerminationStep: Int?) -> (eig_vector: [Double], eig_value: Double)? {
        
        /* Változók inicializálása */
        var v_prev = [Double](repeatElement(0x00, count: sizeOfMatrix))                     // Az előző felírt próbavektor
        var v = [Double](repeatElement(0x00, count: sizeOfMatrix))                          // A próbavektor
        var y = [Double](repeatElement(0x00, count: sizeOfMatrix))                          // A forgatott próbavektor
        var eig_value : Double              = 0x00                                          // A leendő sajátérték
        var w_fault = initVector                                                            // A hibavektor, ami az új próbavektor irányát adja majd
        var B_fault_norm : Double           = 0x00                                          // A hibavektor normáltja
        var S_Matrix : [Double]             = sMatrix                                        // A szimmetrikus mátrix
        
        let sizeOfMatrix32 : Int32          = Int32(sizeOfMatrix)                           // A 32 bites mátrix méret
        var k : Int                         = 0                                             // A ciklus száma
        
        /* Inicializálás */
        B_fault_norm = cblas_dnrm2(sizeOfMatrix32, &w_fault, 1)
        
        /* A ciklus */
        repeat {
            k += 1                                                                          // A ciklus számot növelni kell
            
            v_prev = v                                                                      // Az előző próbavektort megjegyezzük, mert szükség lesz rá később
            
            for i in 0..<sizeOfMatrix {
                v[i] =  w_fault[i] / B_fault_norm                                            // A hiba vektor normalizálása
            }
            
            // A próbavektor forgatása a sajátvektor felé
            cblas_dgemv(CblasRowMajor, CblasNoTrans, sizeOfMatrix32, sizeOfMatrix32, 1, &S_Matrix, sizeOfMatrix32, &v, 1, 0, &y, 1)
            catlas_daxpby(sizeOfMatrix32, (-1)*B_fault_norm, &v, 1, 1, &y, 1)
            
            // A közelítő sajátérték számítása
            eig_value = cblas_ddot(sizeOfMatrix32, &y, 1, &v, 1)
            
            // A hibavektor kiszámítása
            w_fault = y
            //catlas_daxpby(sizeOfMatrix32, eig_value, &v, 1, B_fault_norm, &v_prev, 1)    // Akivonandó tagok összeadása
            catlas_daxpby(sizeOfMatrix32, -eig_value, &v, 1, 1, &w_fault, 1)                     // Kivonás
            
            // A hibavektor Euklideszi normálása
            B_fault_norm = cblas_dnrm2(sizeOfMatrix32, &w_fault, 1)
            
            print("Ez a \(k)-adik kör, a sajátérték becslés:\(eig_value)")
            
        } while (B_fault_norm != 0x00) &&  (k != 100)
        
        return (v, eig_value)
    }
    
    
    
    /* A Lánczos algoritmus egyetlen sajátvektorra */
    // Bemenet: A számolni kívánt mátrix, és mérete
    // Kimenet: A sajátvektor és a sajátérték
    func Lanczos(sMatrix : [Double], sizeOfMatrix: Int, initVector: [Double], forcedTerminationStep: Int?) -> (eig_vector: [Double], eig_value: Double)? {
        
        /* Változók inicializálása */
        var v_prev = [Double](repeatElement(0x00, count: sizeOfMatrix))                     // Az előző felírt próbavektor
        var v = [Double](repeatElement(0x00, count: sizeOfMatrix))                          // A próbavektor
        var y = [Double](repeatElement(0x00, count: sizeOfMatrix))                          // A forgatott próbavektor
        var eig_value : Double              = 0x00                                          // A leendő sajátérték
        var w_fault = initVector                                                            // A hibavektor, ami az új próbavektor irányát adja majd
        var B_fault_norm : Double           = 0x00                                          // A hibavektor normáltja
        var S_Matrix : [Double]             = sMatrix                                        // A szimmetrikus mátrix
        
        let sizeOfMatrix32 : Int32          = Int32(sizeOfMatrix)                           // A 32 bites mátrix méret
        var k : Int                         = 0                                             // A ciklus száma
        
        /* Inicializálás */
        B_fault_norm = cblas_dnrm2(sizeOfMatrix32, &w_fault, 1)
        
        /* A ciklus */
        repeat {
            k += 1                                                                          // A ciklus számot növelni kell
            
            v_prev = v                                                                      // Az előző próbavektort megjegyezzük, mert szükség lesz rá később
            
            for i in 0..<sizeOfMatrix {
                v[i] =  w_fault[i] / B_fault_norm                                            // A hiba vektor normalizálása
            }
            
            // A próbavektor forgatása a sajátvektor felé
            cblas_dgemv(CblasRowMajor, CblasNoTrans, sizeOfMatrix32, sizeOfMatrix32, 1, &S_Matrix, sizeOfMatrix32, &v, 1, 0, &y, 1)
            
            // A közelítő sajátérték számítása
            eig_value = cblas_ddot(sizeOfMatrix32, &y, 1, &v, 1)
            
            // A hibavektor kiszámítása
            w_fault = y
            catlas_daxpby(sizeOfMatrix32, eig_value, &v, 1, B_fault_norm, &v_prev, 1)    // Akivonandó tagok összeadása
            catlas_daxpby(sizeOfMatrix32, -1, &v_prev, 1, 1, &w_fault, 1)                     // Kivonás
            
            // A hibavektor Euklideszi normálása
            B_fault_norm = cblas_dnrm2(sizeOfMatrix32, &w_fault, 1)
            
            print("Ez a \(k)-adik kör, a sajátérték becslés:\(eig_value)")
            
        } while (B_fault_norm != 0x00) &&  (k != 100)
        
        return (v, eig_value)
    }
    
    
    /* Új próbavektor generáló */
    // Bemenet: Az eddigi, egymásra merőleges sajátvektorok, azok száma és hossza
    // Kimenet: Az új próbavektor
    func NewVector(eigVectors : [[Double]], sizeOfMatrix : Int, numberOfVectors : Int) -> [Double] {
        //var v = [Double](repeatElement(0x00, count: sizeOfMatrix))                          // A próbavektor
        var v_new = [Double]()      // A hibavektor, ami az új próbavektor irányát adja majd
        for i in 0..<sizeOfMatrix {
            v_new.append(Double(arc4random()))
        }
        
        var v_norm: Double = 0x00
        var alpha: Double = 0x00
        
        for i in 0..<numberOfVectors {
            var v : [Double] = eigVectors[i]
            var v_mod = [Double](repeatElement(0x00, count: sizeOfMatrix))
            var v_projection = [Double](repeatElement(0x00, count: sizeOfMatrix))
            
            v_norm = cblas_dnrm2(Int32(sizeOfMatrix), &v, 1)
            vDSP_vsdivD(&v, 1, &v_norm, &v_mod, 1, UInt(sizeOfMatrix))
            alpha = cblas_ddot(Int32(sizeOfMatrix), &v_mod, 1, &v_new, 1)
            vDSP_vsmulD(&v_mod, 1, &alpha, &v_projection, 1, UInt(sizeOfMatrix))
            // Kivonás
            catlas_daxpby(Int32(sizeOfMatrix), -1, &v_projection, 1, 1, &v_new, 1)
        }
        return v_new
    }
    
    
    
    /* Mátrix bővítő */
    // Bemenet: A bővíteni kívánt mátrix, a mérete, és az egyes pontok súlya
    // Kimenet: A bővített mátrix, és mérete
    func MatrixExpansion(Matrix: [Double], sizeOfMatrix: Int, weight: [Double]) -> (Matrix: [Double], sizeOfMatrix: Int) {
        // Bemenet újradefiniálása
        var LaplaceMatrix: [[Double]] = []
        
        let sizeOfMatrixInt32 = Int32(sizeOfMatrix)
        let trace: Double = sparse_matrix_trace_double(sparse_matrix_double(Matrix), 0)
        let maxWeight: Double = weight[Int(cblas_idamax(sizeOfMatrixInt32, weight, 1))]
        
        for i in 0..<sizeOfMatrix {
            if weight[i] == 1 {break}                                   // Ha nem kell klikket növeszteni, akkor kilépünk
            
            let klikkWeight = 2*(maxWeight-1)*trace/(weight[i]-1)       // A klikkben szereplő élek súlya
            
            
        }
        return (Matrix,sizeOfMatrix)
    }
    
    func NCut(sourceMatrix: [Double], sizeOfMatrix: Int, groupDensity: Float) -> Bool {
        
        for i in 0..<(sizeOfMatrix*sizeOfMatrix) {
            if sourceMatrix[i].isNaN {
                print("Nem szám is van a forrás mátrixban")
            }
        }
        
        
        /* A Laplace Mátrix létrehozása */
        let LMatrix = makeLaplace(matrix: Matrix, sizeOfMatrix: sizeOfMatrix)
        
        
        /* A kezdeti sajátvektorok és sajátértékek kiszámítása, kisebb pontossággal */
        for i in 0..<sizeOfMatrix {
            print("Az \(i). vektort számolja")
            var startVector = [Double](repeatElement(0x00, count: sizeOfMatrix))                          // A próbavektor
            startVector = NewVector(eigVectors: eigVectorArray, sizeOfMatrix: sizeOfMatrix, numberOfVectors: eigVectorArray.count)
            if let eigvv = Lanczos2(sMatrix: LMatrix, sizeOfMatrix: sizeOfMatrix, initVector: startVector, forcedTerminationStep: Int(sizeOfMatrix/100)) {
                eigVectorArray.append(eigvv.eig_vector)
                eigValueArray.append(eigvv.eig_value)
                print("Az \(i). vektort kiszámolta, sajátérték: \(eigvv.eig_value)")
            }
        }
        
        /* A pontos sajátvektor kiszámítása */
        if let index = eigValueArray.index(of: eigValueArray.min()!) {
            let result = Lanczos2(sMatrix: LMatrix, sizeOfMatrix: sizeOfMatrix, initVector: eigVectorArray[index], forcedTerminationStep: nil)
            minEigValue = result?.eig_value
            minEigVector = (result?.eig_vector)!
        } else {
            NSLog("Nem bírta meghatározni a legkisebb sajátértéket.")
        }
        
        print("A sajátérték: \(minEigValue) \nA sajátvektor: \(minEigVector)")
        
        return true
    }
    
    
    
    
    

    
    override init() {
        super.init()
    }
}







