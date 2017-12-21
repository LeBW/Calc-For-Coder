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
    @available(*, deprecated, message: "Use evaluate instead")
    public var resultIsPending:Bool{
        return evaluate().isPending
    }
    @available(*, deprecated, message: "Use evaluate instead")
    public var description:String {
        return evaluate().description
    }
    @available(*, deprecated, message: "Use evaluate instead")
    public var result:Double?{
        return evaluate().result
    }
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double)->Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }
    
    private enum ExpressionLiteral {
        case operand(Double)
        case operation(String)
        case varible(String)
    }
    private var sequences = [ExpressionLiteral]()
    
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
        "x⁻¹": Operation.unaryOperation({1/$0}),
        "x²": Operation.unaryOperation({$0 * $0}),
        "x!": Operation.unaryOperation(factorial),
        "%": Operation.binaryOperation({ (s1:Double, s2:Double) -> Double in
            return s1.truncatingRemainder(dividingBy: s2)
        }),
        "eˣ": Operation.unaryOperation({pow(M_E, $0)}),
        "xⁿ": Operation.binaryOperation({pow($0, $1)})
    ]
    private var ans: Double?
    private struct PendingBinaryOperaion {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double{
            return function(firstOperand, secondOperand)
        }
    }
    mutating func performOperations(_ symbol:String){
        sequences.append(.operation(symbol))
    }
    mutating func setOperand(_ operand:Double){
        sequences.append(.operand(operand))
    }
    mutating func setOperand(variable named: String) {
        sequences.append(.varible(named))
    }
    mutating func undo(){
        if !sequences.isEmpty {
            sequences.removeLast()
        }
    }
    func evaluate(using variables: Dictionary<String,Double>? = nil) -> (result:Double?, isPending:Bool, description:String){
        var accumulator:Double?
        var description:String = ""
        var tempDescription:String? = nil
        var pendingBinaryOperation:PendingBinaryOperaion? = nil
        var resultIsPending:Bool = false
        func setOperand(_ operand:Double){
            accumulator = operand
            tempDescription = String(format:"%g",  accumulator!)
        }
        func setOperand(variable named:String){
            accumulator = variables?[named] ?? 0
            tempDescription = named
        }
        func performOperations(_ symbol:String){
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
                        if symbol == "x²" || symbol == "x!" {
                            if var temp = tempDescription {
                                temp = " " + temp + String(symbol.last!)
                                if resultIsPending {
                                    description += temp
                                }
                                else{
                                    description = temp
                                }
                                tempDescription = nil
                                
                            }
                            else{
                                description = "(" + description + ")" + String(symbol.last!)
                            }
                        }
                        else if symbol == "eˣ" {
                            if var temp = tempDescription {
                                temp = " exp(" + temp + ")"
                                if (resultIsPending) {
                                    description += temp;
                                }
                                else {
                                    description = temp;
                                }
                                tempDescription = nil
                            }
                            else {
                                description = "exp(" + description + ")"
                            }
                        }
                        else {
                            if var temp = tempDescription {
                                temp = " " + symbol + "(" + temp + ")"
                                if resultIsPending {
                                    description += temp
                                }
                                else{
                                    description = temp
                                }
                                tempDescription = nil
                                
                            }
                            else{
                                description = symbol + "(" + description + ")"
                            }
                        }
                        
                        accumulator = function(accumulator!)
                    }
                    
                case .binaryOperation(let function):
                    if (pendingBinaryOperation == nil || (pendingBinaryOperation != nil && tempDescription != nil)) && accumulator != nil{
                        if pendingBinaryOperation == nil && tempDescription != nil{
                            description = ""
                        }
                        if let temp = tempDescription{
                            description += temp
                            tempDescription = nil
                        }
                        if symbol == "xⁿ" {
                            description += " ^ ";
                        } else {
                            description += " " + symbol + " "
                        }
                        if pendingBinaryOperation != nil{
                            accumulator = pendingBinaryOperation?.perform(with: accumulator!)
                        }
                        pendingBinaryOperation = PendingBinaryOperaion(function: function, firstOperand: accumulator!)
                        resultIsPending = true
                    }
                case .equals:
                    // if pendingBinaryOperation != nil && accumulator != nil{
                    if accumulator != nil {
                        //      description += (" " + String(format:"%g",  accumulator!))
                        if let temp = tempDescription {
                            description += temp
                            tempDescription = nil
                        }
                        if pendingBinaryOperation != nil {
                            accumulator = pendingBinaryOperation?.perform(with: accumulator!)
                            pendingBinaryOperation = nil
                            resultIsPending = false
                        }
                    }
                }
            }
        }

        for element in sequences {
            switch element{
            case .operand(let operand):
                setOperand(operand)
            case .operation(let operation):
                performOperations(operation)
            case .varible(let variable):
                setOperand(variable: variable)
            }
            
        }
        
        return (accumulator, resultIsPending, description)
    }
    
    

}
