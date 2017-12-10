//
//  GraphCalculatorViewController.swift
//  Calculator
//
//  Created by 李博文 on 09/12/2017.
//  Copyright © 2017 Nanjing University. All rights reserved.
//

import UIKit

class GraphCalculatorViewController: UIViewController {
    //MARK: Properties
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var auxDisplay: UILabel!
    @IBOutlet weak var valueofM: UILabel!
    @IBOutlet weak var graphButton: UIButton!
    
    var userIsInTheMiddleOfTyping:Bool = false
    
    //MARK: viewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        graphButton.isEnabled = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    //MARK: Actions
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
                if displayValue != 0 || digit != "0" {
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
    private func evaluate(){
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
            graphButton.isEnabled = false
        }
        else{
            auxDisplay.text = description + " ="
            graphButton.isEnabled = true
        }
        if let m = dictionary.variableDictionary["M"]{
            valueofM.text = "M = \(m)"
        }
        else{
            valueofM.text = " "
        }
    }
    @IBAction func performAction(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping{
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        
        if let mathmaticalSymbol = sender.currentTitle{
            brain.performOperations(mathmaticalSymbol)
        }
        evaluate()
    }
    
    @IBAction func clear(_ sender: UIButton) {
        userIsInTheMiddleOfTyping = false
        displayValue = 0
        auxDisplay.text = " "
        valueofM.text = " "
        brain = CalculatorBrain()
        dictionary = VariableDictionary()
        graphButton.isEnabled = false
    }

    @IBAction func usingVariables(_ sender: UIButton) {
        userIsInTheMiddleOfTyping = false
        if let variable = sender.currentTitle{
            brain.setOperand(variable: variable)
            evaluate()
        }
    }
    @IBAction func Undo(_ sender: UIButton) {
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
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let graphingViewController = segue.destination as? GraphingViewController {
            graphingViewController.unaryFunction = { [weak self] operand in
                self?.dictionary.variableDictionary["X"] = operand
                return self?.brain.evaluate(using: self?.dictionary.variableDictionary).result
            }
            graphingViewController.navigationItem.title = brain.evaluate().description
        }
    }
}

