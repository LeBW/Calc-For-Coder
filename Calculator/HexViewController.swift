//
//  HexViewController.swift
//  Calculator
//
//  Created by 李博文 on 2017/11/24.
//  Copyright © 2017年 Nanjing University. All rights reserved.
//

import UIKit

class HexViewController: UIViewController {

    
    //MARK: Initiate progress
    override func viewDidLoad() {
        super.viewDidLoad()
        //初始化字典 displayLables
        displayLabels = [.hex : hexDisplay, .dec : decDisplay, .bin : binDisplay]
        //初始化字典 digitButton
        initiateDigitButton()
        //当前进制位高亮显示
        setHighlighed()
        //数字按钮根据当前进制进行状态更新
        updateDigitButton()
    }
    //MARK: Properties
    var userIsInTheMiddleOfTyping = false
    var calculateState: CalculateState = .dec {
        didSet {
            updateDigitButton()
            setHighlighed()
            //clear
            if userIsInTheMiddleOfTyping {
                clearAll()
            }
        }
    }
    var decValue: Int {
        get {
            return Int(decDisplay.text!)!
        }
        set {
            updateAllDisplayWith(value: newValue)
        }
    }
    private var brain = CalculatorBrain()
    var ans: Int?
    
    //MARK: Private methods
    ///use the value to update all of three displays(hex, dec, bin)
    private func updateAllDisplayWith(value: Int) {
        
        decDisplay.text = String(value)
        if (decValue >= 0) {
            hexDisplay.text = String(value, radix: 16, uppercase: true)
            binDisplay.text = String(value, radix: 2, uppercase: true)
        }
        else {
            let complement = 0xFFFFFFFF + value + 1
            hexDisplay.text = String(complement, radix: 16, uppercase: true)
            binDisplay.text = String(complement, radix: 2, uppercase: true)
        }
    }
    /// change the useful button according to the Calculator state.
    private func updateDigitButton() {
        //TODO...
        switch calculateState {
        case .bin:
            for (_, button) in digitButton {
                button.isEnabled = false
                button.backgroundColor = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1)
            }
        case .dec:
            for index in 0..<10 {
                digitButton[index]?.isEnabled = true
                digitButton[index]?.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1)
            }
            for index in 10..<16 {
                digitButton[index]?.isEnabled = false
                digitButton[index]?.backgroundColor = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1)
            }
        case .hex:
            for (_, button) in digitButton {
                button.isEnabled = true
                button.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1)
            }
        }
    }
    private func setHighlighed() {
        for (state, label) in displayLabels {
            if state == calculateState {
                label.backgroundColor = UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1)
            }
            else {
                label.backgroundColor = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1)
            }
        }
    }
    private func initiateDigitButton() {
        digitButton[2] = digit2
        digitButton[3] = digit3
        digitButton[4] = digit4
        digitButton[5] = digit5
        digitButton[6] = digit6
        digitButton[7] = digit7
        digitButton[8] = digit8
        digitButton[9] = digit9
        digitButton[10] = digitA
        digitButton[11] = digitB
        digitButton[12] = digitC
        digitButton[13] = digitD
        digitButton[14] = digitE
        digitButton[15] = digitF
    }
    private func clearAll() {
        userIsInTheMiddleOfTyping = false
        decValue = 0
        brain = CalculatorBrain()
    }
    private func popupOverflowAlert() {
        let alert = UIAlertController(title: "Overflow Error", message: "The value is too large!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: clearAll)
    }
    private func popupDividedByZeroAlert() {
        let alert = UIAlertController(title: "Divide Error", message: "Can't divide 0!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: clearAll)
    }
    private func evaluate() {
        let (result, isPending, _) = brain.evaluate()
        if let result = result {
            guard result != Double.nan && result != Double.infinity else {
                popupDividedByZeroAlert()
                return
            }
            decValue = Int(result)
            if !isPending {
                ans = Int(result)
            }
        }
    }
    //MARK: Outlets and actions
    @IBOutlet weak var hexDisplay: UILabel!
    @IBOutlet weak var decDisplay: UILabel!
    @IBOutlet weak var binDisplay: UILabel!
    
    @IBOutlet weak var digit2: UIButton!
    @IBOutlet weak var digit3: UIButton!
    @IBOutlet weak var digit4: UIButton!
    @IBOutlet weak var digit5: UIButton!
    @IBOutlet weak var digit6: UIButton!
    @IBOutlet weak var digit7: UIButton!
    @IBOutlet weak var digit8: UIButton!
    @IBOutlet weak var digit9: UIButton!
    @IBOutlet weak var digitA: UIButton!
    @IBOutlet weak var digitB: UIButton!
    @IBOutlet weak var digitC: UIButton!
    @IBOutlet weak var digitD: UIButton!
    @IBOutlet weak var digitE: UIButton!
    @IBOutlet weak var digitF: UIButton!
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            if decValue != 0 || digit != "0" {
                displayLabels[calculateState]?.text?.append(digit)
            }
        }
        else {
            displayLabels[calculateState]?.text = digit
            userIsInTheMiddleOfTyping = true
        }
        switch calculateState {
        case .dec:
            guard let dv = Int(decDisplay.text!) else {
                // 弹窗警告
                popupOverflowAlert()
                
                //clearAll()
                return
            }
            decValue = dv
        case .bin:
            guard let dv = Int(binDisplay.text!, radix: 2) else {
                popupOverflowAlert()
                //clearAll()
                return
            }
            decValue = dv
        case .hex:
            guard let dv = Int(hexDisplay.text!, radix: 16) else {
                popupOverflowAlert()
                //clearAll()
                return
            }
            decValue = dv
        }
    }
    @IBAction func performAction(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(Double(decValue))
            userIsInTheMiddleOfTyping = false
        }
        if let mathmaticalSymbol = sender.currentTitle {
            brain.performOperations(mathmaticalSymbol)
        }
        evaluate()
    }
    @IBAction func clear(_ sender: UIButton) {
        clearAll()
    }
    @IBAction func undo(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping{
            var currentTyping = displayLabels[calculateState]!.text!
            currentTyping.removeLast()
            if currentTyping == ""{
                userIsInTheMiddleOfTyping = false
                decValue = 0
            }
            else {
                displayLabels[calculateState]!.text = currentTyping
            }
        }
        else{
            brain.undo()
            evaluate()
        }
    }
    @IBAction func ansTapped(_ sender: UIButton) {
        if let ans = ans {
            userIsInTheMiddleOfTyping = false
            brain.setOperand(Double(ans))
            evaluate()
        }
    }
    
    @IBAction func decStateTapped(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            calculateState = .dec
        }
    }
    @IBAction func binStateTapped(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            calculateState = .bin
        }
    }
    @IBAction func hexStateTapped(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            calculateState = .hex
        }
    }
    
    //MARK: Enums and inner classes or constants
    enum CalculateState: Int {
        case hex = 0
        case dec
        case bin
    }
    var displayLabels: [CalculateState : UILabel] = [:]
    var digitButton: [Int: UIButton] = [:]
}
