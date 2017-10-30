//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by xy-nju on 2017/9/24.
//  Copyright © 2017年 Nanjing University. All rights reserved.
//

import Foundation
func factorial(operand:Double) -> Double{
    if operand.truncatingRemainder(dividingBy: 1) != 0{
        return Double.nan //出错
    }
    var intOperand = Int(operand)
    var result = 1
    var isOverflow = false
    while !isOverflow && intOperand > 0{
        (result, isOverflow) = result.multipliedReportingOverflow(by: intOperand)
        intOperand -= 1
    }
    return isOverflow ? Double.nan : Double(result)
}
struct CalculatorBrain{
    private var accumulator:Double?
    public var resultIsPending = false
    public var description:String = ""
    private var tempDescription = ""
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double)->Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
        case AC
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation(sqrt),
        "cos": Operation.unaryOperation(cos),
        "sin": Operation.unaryOperation(sin),
        "tan": Operation.unaryOperation(tan),
        "×": Operation.binaryOperation({ $0 * $1 }),
        "+": Operation.binaryOperation({$0 + $1}),
        "-": Operation.binaryOperation({$0 - $1}),
        "÷": Operation.binaryOperation({$0 / $1}),
        "=": Operation.equals, 
        "±": Operation.unaryOperation({-$0}),
        "ln": Operation.unaryOperation({log($0)/log(M_E)}),
        "log": Operation.unaryOperation({log10($0)}),
        "1/x": Operation.unaryOperation({1/$0}),
        "x²": Operation.unaryOperation({$0 * $0}),
        "x!": Operation.unaryOperation(factorial),
        "%": Operation.binaryOperation({ (s1:Double, s2:Double) -> Double in
            return s1.truncatingRemainder(dividingBy: s2)
        }),
        "AC": Operation.AC
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
                if resultIsPending {
                    description += " " + symbol
                }
                else {
                    description = symbol
                }
                accumulator = value
            case .unaryOperation(let function):
                if accumulator != nil {
                    if resultIsPending {
                        tempDescription = " " + symbol + "(" + tempDescription + ")"
                        description += tempDescription
                        tempDescription = " "
                    }
                    else{
                        description = symbol + "(" + description + ")"
                    }
                    accumulator = function(accumulator!)
                }
                
            case .binaryOperation(let function):
                if accumulator != nil{
                    description += tempDescription
                    tempDescription = " "
                    description += " " + symbol + " "
                    if pendingBinaryOperation != nil{
                        accumulator = pendingBinaryOperation?.perform(with: accumulator!)
                    }
                    pendingBinaryOperation = PendingBinaryOperaion(function: function, firstOperand: accumulator!)
                    resultIsPending = true
                }
            case .equals:
                if pendingBinaryOperation != nil && accumulator != nil{
              //      description += (" " + String(format:"%g",  accumulator!))
                    description += tempDescription
                    tempDescription = " "
                    accumulator = pendingBinaryOperation?.perform(with: accumulator!)
                    pendingBinaryOperation = nil
                    resultIsPending = false
                }
            case .AC:
                accumulator = 0
                description = " "
                tempDescription = " "
                resultIsPending = false
                pendingBinaryOperation = nil
            }
        }
    }
    mutating func setOperand(_ operand:Double){
        accumulator = operand
        tempDescription = String(format:"%g",  accumulator!)
    }
    mutating func tellMeYouAreTypingDigit(){
        if(!resultIsPending){
            accumulator = 0
            description = " "
            resultIsPending = false
            pendingBinaryOperation = nil
        }
    }
    var result:Double?{
        get{
            return accumulator
        }
    }
}
