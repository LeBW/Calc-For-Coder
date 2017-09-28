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
    var userIsInTheMiddleOfTyping:Bool = false
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping{
            let textCurrentlyDisplay = display.text!
            display.text = textCurrentlyDisplay + digit
        }else{
            display.text = digit
            userIsInTheMiddleOfTyping = true
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
        if let result = brain.result{
            displayValue = result
        }
        
    }
    
}

