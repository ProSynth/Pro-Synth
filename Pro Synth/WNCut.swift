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


var eigValueArray: [Double] = []

var minEigVector: [Double] = []
var minEigValue: Double!

class WNCut: NSObject {

    var sourceMatrix: [Double]
    var L_Eigvectors: [[Double]] = []
    var T_Matrix: [[Double]]!
    var g_sizeOfMatrix: Int
    var e_sizeOfMatrix: Int!
    
    init(sizeOfMatrix: Int, sourceMatrix: [Double]) {
        self.sourceMatrix = sourceMatrix
        self.g_sizeOfMatrix = sizeOfMatrix
        
        L_Eigvectors = Array(repeating: Array(repeating: 0.0, count: g_sizeOfMatrix), count: g_sizeOfMatrix)
        super.init()
    }

    
    /* A Laplace Mátrix generáló */
    // Bemenet: Diag vektor, D-W mátrix és a mátrixok mérete
    // Kimenet: A Laplapce mátrix
    private func makeLaplace(matrix: [Double], sizeOfMatrix: Int) -> [Double] {
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
        for i in 0..<sizeOfMatrix {
            if DiagVector[i] == 0 {
                print("A főátlóban 0 van")
            }
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
    private func Lanczos2(sMatrix : [Double], sizeOfMatrix: Int, initVector: [Double], forcedTerminationStep: Int?) -> (eig_vector: [Double], eig_value: [Double])? {
        
        
        var S_Matrix : [Double]             = sMatrix                                        // A szimmetrikus mátrix
        
        var workspace = [Double] (repeating:0.0, count: Int(sizeOfMatrix))
        var error: __CLPK_integer = 0
        var lwork = __CLPK_integer(-1)
        var mekkora = __CLPK_doublereal (0)
        
        var wr = [Double] (repeating:0.0, count: Int(sizeOfMatrix))
        var wi = [Double] (repeating:0.0, count: Int(sizeOfMatrix))
        
        var vl = [__CLPK_doublereal] (repeating:0.0, count: Int(sizeOfMatrix*sizeOfMatrix))
        var vr = [__CLPK_doublereal] (repeating:0.0, count: Int(sizeOfMatrix*sizeOfMatrix))
        
        var sizeOfMatrix32 : __CLPK_integer          = __CLPK_integer(sizeOfMatrix)                           // A 32 bites mátrix méret
        
        
        dgeev_(UnsafeMutablePointer(mutating: ("V" as NSString).utf8String), UnsafeMutablePointer(mutating: ("V" as NSString).utf8String), &sizeOfMatrix32, &S_Matrix, &sizeOfMatrix32, &wr, &wi, &vl, &sizeOfMatrix32, &vr, &sizeOfMatrix32, &mekkora, &lwork, &error )
        
        workspace = [Double] (repeating:0.0, count: Int(mekkora))
        lwork = __CLPK_integer(mekkora)
        
        
        dgeev_(UnsafeMutablePointer(mutating: ("V" as NSString).utf8String), UnsafeMutablePointer(mutating: ("V" as NSString).utf8String), &sizeOfMatrix32, &S_Matrix, &sizeOfMatrix32, &wr, &wi, &vl, &sizeOfMatrix32, &vr, &sizeOfMatrix32, &workspace, &lwork, &error )
        
        
        //print("\(wr)")
        
        return (vr, wr)
    }
    
    
    
    /* A Lánczos algoritmus egyetlen sajátvektorra */
    // Bemenet: A számolni kívánt mátrix, és mérete
    // Kimenet: A sajátvektor és a sajátérték
    private func Lanczos(sMatrix : [Double], sizeOfMatrix: Int, initVector: [Double], forcedTerminationStep: Int?) -> ([Double])? {
        
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
        var T = [Double](repeatElement(0x00, count: sizeOfMatrix+(sizeOfMatrix-1)))
        
        /* Inicializálás */
        B_fault_norm = cblas_dnrm2(sizeOfMatrix32, &w_fault, 1)
        
        
        /* A ciklus */
        repeat {
            k += 1                                                                          // A ciklus számot növelni kell
            
            v_prev = v                                                                      // Az előző próbavektort megjegyezzük, mert szükség lesz rá később
            L_Eigvectors.append(v)                                                          // Feltöltjük a Q mátrixot is
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
            print("Ez a \(k)-adik kör, a hiba:\(B_fault_norm)")
            //print("Sajátvektor: \(v)")
            
            T_Matrix[k-1][k-1] = eig_value
            if k < sizeOfMatrix {
                T_Matrix[k][k-1] = B_fault_norm
                T_Matrix[k-1][k] = B_fault_norm
            }
            
            T[k-1] = eig_value
            if k < (sizeOfMatrix) {
                T[sizeOfMatrix+k-1] = B_fault_norm
            }
            
        } while  (k != sizeOfMatrix)
        
        return (T)
    }
    
    
    private func tridiagToEigValues(symTridiagMatrix: [Double], sizeOfMatrix:Int) -> [Double] {
        var info: __CLPK_integer                            = __CLPK_integer(0)
        var CLPKsizeOfMatrix: __CLPK_integer                = __CLPK_integer(sizeOfMatrix)
        var numOfSuperdiagonals: __CLPK_integer             = __CLPK_integer(1)
        let jobz                                            = UnsafeMutablePointer(mutating: ("N" as NSString).utf8String)
        let uplo                                            = UnsafeMutablePointer(mutating: ("L" as NSString).utf8String)
        var lwork: __CLPK_integer                           = __CLPK_integer(2*sizeOfMatrix)
        var liwork: __CLPK_integer                          = __CLPK_integer(1)
        var S_Matrix: [__CLPK_doublereal]                   = Array(repeatElement(__CLPK_doublereal(0), count: sizeOfMatrix*sizeOfMatrix))
        var eig_Vectors: [__CLPK_doublereal]                = Array(repeatElement(__CLPK_doublereal(0), count: sizeOfMatrix))
        var eigValues: [__CLPK_doublereal]                  = Array(repeatElement(__CLPK_doublereal(0), count: sizeOfMatrix))
        var work = [Double] (repeating:0.0, count: Int(lwork))
        var work2 = [Double] (repeating:0.0, count: Int(3*sizeOfMatrix-2))
        var iwork = [Int32] (repeating:0, count: Int(liwork))
        /*
        for i in 1..<sizeOfMatrix {
            S_Matrix[i] = symTridiagMatrix[sizeOfMatrix+i-1]
        }
        */
        for i in 0..<(sizeOfMatrix) {
            S_Matrix[sizeOfMatrix*i] = symTridiagMatrix[i]
        }
        for i in 0..<sizeOfMatrix-1 {
            S_Matrix[sizeOfMatrix*i+1] = symTridiagMatrix[sizeOfMatrix+i]
        }

        dsbev_(jobz,                                                    // Csak sajátértéket számoljon
            uplo,                                                    // A felső háromszög mátrixot számolja
            &CLPKsizeOfMatrix,                                       // A mátrix mérete
            &numOfSuperdiagonals,                                    // Mivel a mátrix szimmetrikus tridiagonal, ezért 1
            &(S_Matrix)                                      ,       // A mátrix
            &CLPKsizeOfMatrix,                                       // A mátrix másik mérete
            &eigValues,                                              // A sajátrtékek vektora
            &eig_Vectors,                                            // A sajátvektorok helye (ami nem lesz most)
            &CLPKsizeOfMatrix,                                       // A sajátvektor mérete
            &work2,                                                   // Workspace, nem tudom minek...
            &info)                                                   // Az infoba kerül vissza a hibajelentés
        return eigValues
    }
    
    
    /* Új próbavektor generáló */
    // Bemenet: Az eddigi, egymásra merőleges sajátvektorok, azok száma és hossza
    // Kimenet: Az új próbavektor
    private func NewVector(sizeOfMatrix : Int) -> [Double] {
        //var v = [Double](repeatElement(0x00, count: sizeOfMatrix))                          // A próbavektor
        var v_new = [Double]()      // A hibavektor, ami az új próbavektor irányát adja majd
        for i in 0..<sizeOfMatrix {
            v_new.append(Double(arc4random()))
        }
        
        var v_norm: Double = 0x00
        var alpha: Double = 0x00
        /*
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
 */
        return v_new
    }
    
    
    
    /* Mátrix bővítő */
    // Bemenet: A bővíteni kívánt mátrix, a mérete, és az egyes pontok súlya
    // Kimenet: A bővített mátrix, és mérete
    private func MatrixExpansion(sMatrix: [Double], sizeOfsMatrix: Int, weight: [Int]) -> (dMatrix: [Double], sizeOfdMatrix: Int) {
        // Bemenet újradefiniálása
        var sizeOfdMatrix: Int          = 0
        for i in 0..<weight.count {
            sizeOfdMatrix += weight[i]
        }
        var destinationMatrix: [[Double]] = Array(repeating: Array(repeating: 0.0, count: sizeOfdMatrix), count: sizeOfdMatrix)
        
        
        var trace: Double = 0
        for i in 0..<sizeOfsMatrix{
            trace += sMatrix[i*sizeOfsMatrix+i]
        }
        
        let maxWeight: Int = weight.max()!
        var weightCounter: Int = 0
        
        for i in 0..<weight.count {
            if weight[i] > 0 {
                if weight[i] > 1 {
                    let n = Double(2*(maxWeight-1))*trace
                    let d = Double(weight[i]-1)
                    let klikk_weight = n/d
                    
                    
                    for j in weightCounter...weightCounter+weight[i] {
                        for k in weightCounter...weightCounter+weight[i] {
                            if j != k {
                                destinationMatrix[j][k] = -klikk_weight
                            }
                        }
                    }
                }
                
                var columnCounter: Int = 0
                for j in 0..<sizeOfsMatrix {
                    if i != j {
                       destinationMatrix[weightCounter][columnCounter] = sMatrix[i*sizeOfsMatrix+j]
                    }
                    columnCounter += weight[j]
                }
                
                weightCounter += weight[i]
            } else {
                print("Van 0-ás súlyú pont a mátrixban")
            }
        }
        
        // A főátló feltöltése
        for j in 0..<sizeOfdMatrix {
            var rowSum : Double = 0
            for i in 0..<(sizeOfdMatrix) {
                rowSum = rowSum + destinationMatrix[j][i]
            }
            destinationMatrix[j][j] = (-1)*rowSum
        }
        
        var dMatrix: [Double] = Array(repeating: 0.0, count: sizeOfdMatrix*sizeOfdMatrix)
        
        for i in 0..<sizeOfdMatrix {
            for j in 0..<sizeOfdMatrix {
                dMatrix[i*sizeOfdMatrix+j] = destinationMatrix[i][j]
            }
        }
        
        return (dMatrix,sizeOfdMatrix)
    }
    
    

    
    /* Gauss elimináló */
    // Bemenet: Az eredeti, laplacolt, súlyozott mátrix, a sajátérték, és a mátrix mérete
    // Kimenet: A sajátértékek, és sorrendjük
    private func GaussElimination(sMatrix: [Double], eigValue: Double, sizeOfMatrix: Int) -> (Spectrum: [Double], Group: [Int]) {
        var eigVector: [Double] = Array(repeating: 0.0, count: sizeOfMatrix)
        var eigVectorTmp: [Double] = Array(repeating: 0.0, count: sizeOfMatrix)
        var eigVectorOrder: [Int] = Array(repeating: 0, count: sizeOfMatrix)
        var G_Matrix: [[Double]] = Array(repeating: Array(repeating: 0.0, count: sizeOfMatrix+2), count: sizeOfMatrix)
        
        for i in 0..<sizeOfMatrix {
            for j in 0..<sizeOfMatrix {
                G_Matrix[i][j] = sMatrix[i*sizeOfMatrix+j]
                if i==j {
                    G_Matrix[i][j]-=eigValue
                }
            }
        }
        for i in 0..<sizeOfMatrix {
            eigVectorOrder[i] = i
            G_Matrix[i][sizeOfMatrix+1] = Double(i)
        }
        
        
        for i in 0..<sizeOfMatrix {
            // Keressük meg a maximumot az adott oszlopban
            var maxEl: Double               = abs(G_Matrix[i][i])
            var maxRow: Int                 = i
            for k in i+1..<sizeOfMatrix {
                let absValue = G_Matrix[k][i]
                if absValue > maxEl {
                    maxEl = absValue
                    maxRow = k
                }
            }
            // Kicseréljük a max sort a jelenlegivel
            for k in i..<sizeOfMatrix+2 {
                let tmp: Double = G_Matrix[maxRow][k]
                G_Matrix[maxRow][k] = G_Matrix[i][k]
                G_Matrix[i][k] = tmp
            }
            let tmpOrd: Int = eigVectorOrder[maxRow]
            eigVectorOrder[maxRow] = eigVectorOrder[i]
            eigVectorOrder[i] = tmpOrd
            
            
            // Kinullázzuk az alatta lévő sorokat alatta
            for k in i+1..<sizeOfMatrix {
                let c: Double = -G_Matrix[k][i]/G_Matrix[i][i]
                for j in i..<sizeOfMatrix+1 {
                    
                    if i==j {
                        G_Matrix[k][j] = 0
                    }
                    else {
                        G_Matrix[k][j] += c * G_Matrix[i][j]
                    }
                }
            }
        }
        
        // A felső háromszögmátrix megoldása
        var csoport: Int = 1
        var groupTmp: [Int] = Array(repeating: 0, count: sizeOfMatrix)
        var group: [Int] = Array(repeating: 0, count: sizeOfMatrix)
        
        for i in stride(from: sizeOfMatrix-1, through: 0, by: -1) {
            if (i==sizeOfMatrix-1) {
                eigVectorTmp[i] = 1.0
                groupTmp[i] = csoport
            }
            else {
                eigVectorTmp[i] = G_Matrix[i][sizeOfMatrix]/G_Matrix[i][i]
                groupTmp[i] = csoport
            }
            if ((eigVectorTmp[i] == 0) && (G_Matrix[i][sizeOfMatrix]==0))
            {
                csoport += 1
                eigVectorTmp[i] = 1.0
                groupTmp[i] = csoport
            }
            
            
            
            for k in stride(from: i-1, through: 0, by: -1) {
                G_Matrix[k][sizeOfMatrix] -= G_Matrix[k][i] * eigVectorTmp[i]
            }
        }
        
        for i in 0..<eigVectorOrder.count {
            eigVector[eigVectorOrder[i]] = eigVectorTmp[i]
            group[eigVectorOrder[i]] = groupTmp[i]
        }
        
        return (eigVector, group)
    }
    
    func NCut() -> (Spectrum: [Double], Group: [Int]) {
        // Inicializálás
        T_Matrix = Array(repeating: Array(repeating: 0.0, count: g_sizeOfMatrix), count: g_sizeOfMatrix)
        
        let LMatrix = makeLaplace(matrix: sourceMatrix, sizeOfMatrix: g_sizeOfMatrix)
        
        let tridiag: [Double] = Lanczos(sMatrix: LMatrix, sizeOfMatrix: g_sizeOfMatrix, initVector: NewVector(sizeOfMatrix: g_sizeOfMatrix), forcedTerminationStep: nil)!
        let eigValues: [Double] = tridiagToEigValues(symTridiagMatrix: tridiag, sizeOfMatrix: g_sizeOfMatrix)
        var minEigValue: Double!
        for i in 0..<g_sizeOfMatrix {
            if ((eigValues[i] < 0)  || (eigValues[i] < 1e-10)) {
                
            }
            else {
                minEigValue = eigValues[i]
                break
            }
        }
        
        let eigVectorMin = GaussElimination(sMatrix: LMatrix, eigValue: minEigValue, sizeOfMatrix: g_sizeOfMatrix)
        
        print(eigValues)
        print(eigVectorMin)
        return (eigVectorMin.Spectrum, eigVectorMin.Group)
    }
    
    
    func WNCut(weight: [Int]) -> (Spectrum: [Double], Group: [Int], NodeIDCoder: [Int]) {
        
        
        let EMatrix = MatrixExpansion(sMatrix: sourceMatrix, sizeOfsMatrix: g_sizeOfMatrix, weight: weight)
        e_sizeOfMatrix = EMatrix.sizeOfdMatrix
        
        // Inicializálás
        T_Matrix = Array(repeating: Array(repeating: 0.0, count: e_sizeOfMatrix), count: e_sizeOfMatrix)
        
        
        let LEMatrix = makeLaplace(matrix: EMatrix.dMatrix, sizeOfMatrix: e_sizeOfMatrix)
        
        let tridiag = Lanczos(sMatrix: LEMatrix, sizeOfMatrix: e_sizeOfMatrix, initVector: NewVector(sizeOfMatrix: e_sizeOfMatrix), forcedTerminationStep: nil)
        
        let eigValues: [Double] = tridiagToEigValues(symTridiagMatrix: tridiag!, sizeOfMatrix: e_sizeOfMatrix)
        
        var minEigValue: Double!
        for i in 0..<e_sizeOfMatrix {
            if ((eigValues[i] < 0)  || (eigValues[i] < 1e-10)) {
                
            }
            else {
                minEigValue = eigValues[i]
                break
            }
        }
        
        let eigVectorMin = GaussElimination(sMatrix: LEMatrix, eigValue: minEigValue, sizeOfMatrix: e_sizeOfMatrix)
        
        print(eigValues)
        print(eigVectorMin)
        
        var NodeIDCoder: [Int] = []
        for i in 0..<weight.count {
            for j in 0..<weight[i] {
                NodeIDCoder.append(i)
            }
        }

        
        
        return (eigVectorMin.Spectrum, eigVectorMin.Group, NodeIDCoder)
    }
    
    

    

}







