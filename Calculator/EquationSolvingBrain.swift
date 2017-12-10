//
//  EquationSolvingBrain.swift
//  Calculator
//
//  Created by 李博文 on 07/12/2017.
//  Copyright © 2017 Nanjing University. All rights reserved.
//

import Foundation

struct EquationSolvingBrain {
    func quadraticEquationSolving(quadraticTerm a: Double, primaryTerm b: Double, constant c: Double) -> (Double, Double)? {
        let delta = b*b - 4*a*c
        guard delta >= 0 else {return nil}
        let x1 = (-b + sqrt(delta))/(2*a)
        let x2 = (-b - sqrt(delta))/(2*a)
        return (x1, x2)
    }
    func twoUnknowsEquationSolving(a1: Double, b1: Double, c1: Double, a2: Double, b2: Double, c2:Double) -> (Double, Double)? {
        if(a1*b2 == a2*b1) {
            return nil
        }
        let x = (b1*c2 - c1*b2) / (a1*b2 - a2*b1)
        let y = (a1*c2 - a2*c1) / (a2*b1 - a1*b2)
        return (x, y)
    }
    func threeUnknowsEquationSolving(a1: Double, b1: Double, c1: Double, d1: Double, a2: Double, b2: Double, c2: Double, d2: Double, a3: Double, b3: Double, c3: Double, d3: Double) -> (Double, Double, Double)? {
        let delta = a1*b2*c3 + a2*b3*c1 + a3*b1*c2 - a1*b3*c2 - a2*b1*c3 - a3*b2*c1
        if delta == 0 {
            return nil
        }
        let x = (d1*b3*c2 + d2*b1*c3 + d3*b2*c1 - d1*b2*c3 - d2*b3*c1 - d3*b1*c2) / delta
        let y = (a1*d3*c2 + a2*d1*c3 + a3*d2*c1 - a1*d2*c3 - a2*d3*c1 - a3*d1*c2) / delta
        let z = (a1*b3*d2 + a2*b1*d3 + a3*b2*d1 - a1*b2*d3 - a2*b3*d1 - a3*b1*d2) / delta
        return (x, y, z)
    }
}
