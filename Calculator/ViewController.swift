//
//  ViewController.swift
//  Calculator
//
//  Created by xy-nju on 2017/9/22.
//  Copyright © 2017年 Nanjing University. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    
    
    @IBOutlet weak var auxDisplay: UILabel!
    
    var userIsInTheMiddleOfTyping:Bool = false
    @IBAction func touchDigit(_ sender: UIButton) {
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
                let textCurrentlyDisplay = display.text!
                display.text = textCurrentlyDisplay + digit
            }else{
                display.text = digit
                if(digit != "0"){
                    userIsInTheMiddleOfTyping = true
                }
            }
        }
    }
    var displayValue: Double{
        get{
            return Double(display.text!)!
        }
        set{
            display.text = String(format: "%g",  newValue)
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction func performAction(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping{
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathmaticalSymbol = sender.currentTitle{
           brain.performOperations(mathmaticalSymbol)
        }
        let (result, isPending, description) = brain.evaluate()
        if result != nil {
            //could add something here to change view
            displayValue = result!
        }
        
        if isPending{
            auxDisplay.text = description + " ..."
        }
        else{
            auxDisplay.text = description + " ="
        }
    }
    
}

