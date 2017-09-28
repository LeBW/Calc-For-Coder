//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by xy-nju on 2017/9/24.
//  Copyright © 2017年 Nanjing University. All rights reserved.
//

import Foundation

struct CalculatorBrain{
    private var accumulator:Double?
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double)->Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation(sqrt),
        "cos": Operation.unaryOperation(cos),
        "×": Operation.binaryOperation({ $0 * $1 }),
        "+": Operation.binaryOperation({$0 + $1}),
        "-": Operation.binaryOperation({$0 - $1}),
        "÷": Operation.binaryOperation({$0 / $1}),
        "=": Operation.equals, 
        "±": Operation.unaryOperation({-$0})
    ]
    private struct PendingBinaryOperaion {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double{
            return function(firstOperand, secondOperand)
        }
    }
    private var pendingBinaryOperation:PendingBinaryOperaion? = nil
    mutating func performOperations(_ symbol:String){
        /*
        switch symbol {
        case "π":
            accumulator = Double.pi
        case "√":
            if let result = accumulator{
                accumulator = sqrt(result)
            }
        default:
            break
        }
         */
        if let operation = operations[symbol]{
            switch operation {
            case .constant(let value):
                accumulator = value
            case .unaryOperation(let function):
                if accumulator != nil{
                accumulator = function(accumulator!)
                }
            case .binaryOperation(let function):
                if accumulator != nil{
                    pendingBinaryOperation = PendingBinaryOperaion(function: function, firstOperand: accumulator!)
                }
            case .equals:
                if pendingBinaryOperation != nil && accumulator != nil{
                    accumulator = pendingBinaryOperation?.perform(with: accumulator!)
                    pendingBinaryOperation = nil
                }
            }
        }
    }
    mutating func setOperand(_ operand:Double){
        accumulator = operand
    }
    var result:Double?{
        get{
            return accumulator
        }
    }
}
