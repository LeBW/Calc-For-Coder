//
//  QuadraticViewController.swift
//  Calculator
//
//  Created by 李博文 on 2017/12/6.
//  Copyright © 2017年 Nanjing University. All rights reserved.
//

import UIKit

class QuadraticViewController: UIViewController {
    //MARK: Properties
    let brain = EquationSolvingBrain()
    let ACCEPTABLE_CHARACTERS = "0123456789.-"
    var activeTextField: UITextField?
    //MARK: UI things
    //expression label
    @IBOutlet weak var expressionLabel: UILabel!
    //Text Field
    @IBOutlet weak var quadraticTerm: UITextField!
    @IBOutlet weak var primaryTerm: UITextField!
    @IBOutlet weak var constantTerm: UITextField!

    //Compute button
    @IBOutlet weak var computeButton: UIButton!
    
    @IBAction func compute(_ sender: UIButton) {
        if let activeField = activeTextField {
            activeField.resignFirstResponder()
        }
        guard let a = Double(quadraticTerm.text!), let b = Double(primaryTerm.text!), let c = Double(constantTerm.text!) else {
            popOverArgumentError()
            x1Label.text = " "
            x2Label.text = " "
            return
        }
        guard let (x1, x2) = brain.quadraticEquationSolving(quadraticTerm: a, primaryTerm: b, constant: c) else {
            popOverSolutionError()
            x1Label.text = " "
            x2Label.text = " "
            return
        }
        x1Label.text = "X₁ = " + String(x1)
        x2Label.text = "X₂ = " + String(x2)
    }
    //Result Label
    @IBOutlet weak var x1Label: UILabel!
    @IBOutlet weak var x2Label: UILabel!
    
    
    @IBAction func tapEntireView(_ sender: UITapGestureRecognizer) {
        if let activeField = activeTextField {
            activeField.resignFirstResponder()
        }
    }
    //MARK: ViewController things
    override func viewDidLoad() {
        super.viewDidLoad()
        
        quadraticTerm.delegate = self;
        primaryTerm.delegate = self;
        constantTerm.delegate = self;
        
        quadraticTerm.keyboardType = .numbersAndPunctuation
        primaryTerm.keyboardType = .numbersAndPunctuation
        constantTerm.keyboardType = .numbersAndPunctuation
        
        quadraticTerm.addTarget(self, action: #selector(textFieldDidChanged), for: .editingChanged)
        primaryTerm.addTarget(self, action: #selector(textFieldDidChanged), for: .editingChanged)
        constantTerm.addTarget(self, action: #selector(textFieldDidChanged), for: .editingChanged)
        
        computeButton.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Private methods
    func updateComputeButtonStates() {
        if quadraticTerm.text != "" && primaryTerm.text != "" && constantTerm.text != "" {
            computeButton.isEnabled = true
        }
        else {
            computeButton.isEnabled = false
        }
    }
    @objc func textFieldDidChanged(textfield: UITextField) {
        updateComputeButtonStates()
    }
    func popOverArgumentError() {
        let alert = UIAlertController(title: "参数传入错误！", message: "请传入正确的参数", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .destructive, handler: nil))
        self.present(alert, animated: false, completion: nil)
    }
    func popOverSolutionError() {
        let alert = UIAlertController(title: "此方程无解！", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .destructive, handler: nil))
        self.present(alert, animated: false, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension QuadraticViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let cs = CharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
        let filtered = string.components(separatedBy: cs).joined(separator: "")
        return (string == filtered)
    }
}
