//
//  AdvancedViewController.swift
//  Calculator
//
//  Created by xy-nju on 2017/9/22.
//  Copyright © 2017年 Nanjing University. All rights reserved.
//

import UIKit

class AdvancedViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var auxDisplay: UILabel!
    @IBOutlet weak var valueofM: UILabel!
    
    //var delegate: AdvancedViewControllerDelegate?
    
    var userIsInTheMiddleOfTyping:Bool = false
    @IBAction func touchDigit(_ sender: UIButton)
    {
        //brain.evaluate()
        
        let digit = sender.currentTitle!
        if digit == "." {
            if display.text!.contains(".") {
               return
            }
            if userIsInTheMiddleOfTyping{
                let textCurrentDisplay = display.text!
                display.text = textCurrentDisplay + digit
            }
            else{
                display.text = "0" + digit
                userIsInTheMiddleOfTyping = true
            }
        }
        else
        {
            if userIsInTheMiddleOfTyping{
                if displayValue != 0 || digit != "0" || display.text!.contains("."){
                    let textCurrentlyDisplay = display.text!
                    display.text = textCurrentlyDisplay + digit
                }
            }
            else{
                display.text = digit
                userIsInTheMiddleOfTyping = true
            }
        }
    }
    var displayValue: Double {
        get{
            return Double(display.text!)!
        }
        set{
            display.text = String(format: "%g",  newValue)
        }
    }
    
    private var brain = CalculatorBrain()
    private var dictionary = VariableDictionary()
    private func evaluate()
    {
        let (result, isPending, description) = brain.evaluate(using: dictionary.variableDictionary)
        if result != nil {
            //could add something here to change view
            displayValue = result!
            if result == 520 {
                display.text = "I love you, my Gloria"
            }
        }
        
        if isPending{
            auxDisplay.text = description + " ..."
        }
        else{
            auxDisplay.text = description + " ="
        }
        if let m = dictionary.variableDictionary["M"]{
            valueofM.text = "M = \(m)"
        }
        else{
            valueofM.text = " "
        }
    }
    @IBAction func performAction(_ sender: UIButton)
    {
        if userIsInTheMiddleOfTyping{
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        
        if let mathmaticalSymbol = sender.currentTitle{
           brain.performOperations(mathmaticalSymbol)
        }
        evaluate()
    }
    
    @IBAction func clear(_ sender: UIButton)
    {
        userIsInTheMiddleOfTyping = false
        displayValue = 0
        auxDisplay.text = " "
        valueofM.text = " "
        brain = CalculatorBrain()
        dictionary = VariableDictionary()
    }
    @IBAction func addVariables(_ sender: UIButton)
    {
        userIsInTheMiddleOfTyping  = false
        if var str = sender.currentTitle {
            str.removeFirst()
            dictionary.variableDictionary[str] = displayValue
        }
        //back to evaluate
        evaluate()
    }
    @IBAction func usingVariables(_ sender: UIButton)
    {
        userIsInTheMiddleOfTyping = false
        if let variable = sender.currentTitle{
            brain.setOperand(variable: variable)
            evaluate()
        }
    }
    @IBAction func Undo(_ sender: UIButton)
    {
        if userIsInTheMiddleOfTyping{
            var currentTyping = display.text!
            currentTyping.removeLast()
            if currentTyping == ""{
                userIsInTheMiddleOfTyping = false
                displayValue = 0
            }
            else {
                display.text = currentTyping
            }
        }
        else{
            brain.undo()
            evaluate()
        }
    }
}

/*
@objc
protocol AdvancedViewControllerDelegate {
    @objc optional func collapseSidePanel()
}
 */
