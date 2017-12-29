//
//  TwoUnknowsViewController.swift
//  Calculator
//
//  Created by 李博文 on 07/12/2017.
//  Copyright © 2017 Nanjing University. All rights reserved.
//

import UIKit

class TwoUnknowsViewController: UIViewController {
    //MARK: Properties
    let brain = EquationSolvingBrain()
    let ACCEPTABLE_CHARACTERS = "0123456789.-"
    var activeTextField: UITextField?
    
    //MARK: UI things
    @IBOutlet weak var a1Field: UITextField!
    @IBOutlet weak var b1Field: UITextField!
    @IBOutlet weak var c1Field: UITextField!
    @IBOutlet weak var a2Field: UITextField!
    @IBOutlet weak var b2Field: UITextField!
    @IBOutlet weak var c2Field: UITextField!
    
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    
    @IBOutlet weak var computeButton: UIButton!
    
    @IBAction func compute(_ sender: UIButton) {
        if let activeField = activeTextField {
            activeField.resignFirstResponder()
        }
        guard let a1 = Double(a1Field.text!), let b1 = Double(b1Field.text!), let c1 = Double(c1Field.text!), let a2 = Double(a2Field.text!), let b2 = Double(b2Field.text!), let c2 = Double(c2Field.text!) else {
            popOverArgumentError()
            xLabel.text = " "
            yLabel.text = " "
            return
        }
        guard let (x, y) = brain.twoUnknowsEquationSolving(a1: a1, b1: b1, c1: c1, a2: a2, b2: b2, c2: c2) else {
            popOverSolutionError()
            xLabel.text = " "
            yLabel.text = " "
            return
        }
        xLabel.text = "x = " + String(x)
        yLabel.text = "y = " + String(y)
    }
    
    @IBAction func tapEntireView(_ sender: UITapGestureRecognizer) {
        if let activeField = activeTextField {
            activeField.resignFirstResponder()
        }
    }
    
    
    //MARK: View Controller
    override func viewDidLoad() {
        super.viewDidLoad()

        a1Field.delegate = self
        b1Field.delegate = self
        c1Field.delegate = self
        a2Field.delegate = self
        b2Field.delegate = self
        c2Field.delegate = self
        
        a1Field.keyboardType = .numbersAndPunctuation
        b1Field.keyboardType = .numbersAndPunctuation
        c1Field.keyboardType = .numbersAndPunctuation
        a2Field.keyboardType = .numbersAndPunctuation
        b2Field.keyboardType = .numbersAndPunctuation
        c2Field.keyboardType = .numbersAndPunctuation
        
        a1Field.addTarget(self, action: #selector(textFieldDidChanged), for: .editingChanged)
        b1Field.addTarget(self, action: #selector(textFieldDidChanged), for: .editingChanged)
        c1Field.addTarget(self, action: #selector(textFieldDidChanged), for: .editingChanged)
        a2Field.addTarget(self, action: #selector(textFieldDidChanged), for: .editingChanged)
        b2Field.addTarget(self, action: #selector(textFieldDidChanged), for: .editingChanged)
        c2Field.addTarget(self, action: #selector(textFieldDidChanged), for: .editingChanged)
        
        computeButton.isEnabled = false

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Private methods
    func updateComputeButtonStates()
    {
        if a1Field.text != "" && b1Field.text != "" && c1Field.text != "" && a2Field.text != "" && b2Field.text != "" && c2Field.text != ""{
            computeButton.isEnabled = true
        }
        else {
            computeButton.isEnabled = false
        }
    }
    @objc func textFieldDidChanged(textfield: UITextField) {
        updateComputeButtonStates()
    }
    func popOverArgumentError()
    {
        let alert = UIAlertController(title: "参数传入错误！", message: "请传入正确的参数", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .destructive, handler: nil))
        self.present(alert, animated: false, completion: nil)
    }
    func popOverSolutionError()
    {
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

extension TwoUnknowsViewController: UITextFieldDelegate
{
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
