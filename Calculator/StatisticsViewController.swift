//
//  StatisticsViewController.swift
//  Calculator
//
//  Created by 李博文 on 21/12/2017.
//  Copyright © 2017 Nanjing University. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController {
    //MARK: Properties
    let ACCEPTABLE_CHARACTERS = "0123456789.-"
    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    private var originalKeyboardHeight: CGFloat? = nil
    
    public var activeTextField: UITextField?
    
    private var tapGestureRecognizer: UITapGestureRecognizer!
    private var hasMoveDown = false
    //MARK: Model
    var variable: [Double] = []
    //MARK: Actions
    @IBAction func addVariable(_ sender: UIButton) {
        guard let value = Double(inputField.text ?? "") else {
            let alert = UIAlertController(title: "非法数值", message: "请输入一个实数", preferredStyle: .alert)
            let closeButton = UIAlertAction(title: "Close", style: .cancel, handler: nil)
            alert.addAction(closeButton)
            present(alert, animated: true, completion: nil)
            return
        }
        variable.append(value)
        inputField.text = ""
        tableView.reloadData()
        let indexPath = IndexPath(item: variable.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    @IBAction func deleteVariable(_sender: UIBarButtonItem, forEvent event: UIEvent) {
        guard let touch = event.allTouches?.first else {
            return
        }
        if touch.tapCount == 1 {
            if tableView.isEditing {
                tableView.setEditing(false, animated: true)
            }
            else {
                tableView.setEditing(true, animated: true)
            }
        }
        else if touch.tapCount == 0 {
           // print("Long press")
            let alertController = UIAlertController(title: "确定要删除所有变量吗", message: "", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
                self?.variable.removeAll()
                self?.tableView.reloadData()
            }
            let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelButton)
            alertController.addAction(okButton)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    
    //MARK: ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputField.delegate = self
        inputField.keyboardType = .numbersAndPunctuation
        
        tableView.dataSource = self
        tableView.delegate = self
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapEntireView(_:)))
        
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        if variable.isEmpty {
            inputField.becomeFirstResponder()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: self.view.window)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let resultTableViewController = segue.destination as? ResultTableViewController else {
            fatalError("Unexpected Destination")
        }
        resultTableViewController.variables = variable
    }
    
    //MARK: Private methods
    @objc func keyboardWillShow(_ notification: Notification) {
        if let info = notification.userInfo {
            print("keyboard will show")
            hasMoveDown = false
            let rect = info["UIKeyboardFrameEndUserInfoKey"] as! CGRect
            var upDistance: CGFloat = 0
            if (originalKeyboardHeight == nil) {
                originalKeyboardHeight = rect.height
                upDistance = originalKeyboardHeight!
            }
            else {
                upDistance = rect.height - originalKeyboardHeight!
                originalKeyboardHeight = rect.height
            }
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                self?.bottomConstraint.constant += upDistance
                }, completion: scrollToBottom)
            tableView.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    func scrollToBottom(_: Bool) {
        if let activeTextField = activeTextField {
            if activeTextField.placeholder! == "输入变量值" && variable.count > 0{
                //选中最后一行
                let indexPath = IndexPath(item: variable.count - 1, section: 0)
                tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if let info = notification.userInfo , !hasMoveDown{
            hasMoveDown = true
            originalKeyboardHeight = nil
            let rect = info["UIKeyboardFrameEndUserInfoKey"] as! CGRect
            print("keyboard will hide:\(rect.height)")
            
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                self?.bottomConstraint.constant -= rect.height
                }, completion: nil)
            
            tableView.removeGestureRecognizer(tapGestureRecognizer)
        }
    }
    @objc func tapEntireView(_ sender: UITapGestureRecognizer) {
        if let activeTextField  = activeTextField {
            activeTextField.resignFirstResponder()
        }
    }
}
extension StatisticsViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let index = Int(textField.placeholder ?? "") {
            guard let value = Double(textField.text ?? "") else {
                let alert = UIAlertController(title: "非法数值", message: "请输入一个实数", preferredStyle: .alert)
                let closeButton = UIAlertAction(title: "Close", style: .cancel, handler: nil)
                alert.addAction(closeButton)
                present(alert, animated: true, completion: nil)
                return false
            }
            variable[index] = value
            tableView.reloadData()
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let cs = CharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
        let filtered = string.components(separatedBy: cs).joined(separator: "")
        return (string == filtered)
    }
}
extension StatisticsViewController: UITableViewDataSource , UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return variable.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VariableCell")!  as! VariableTableViewCell
        let data = variable[indexPath.row]
        cell.variableValue.keyboardType = .numbersAndPunctuation
        cell.variableValue.delegate = self
        cell.variableName.text = "X\(indexPath.row+1)"
        cell.variableValue.text = String(data)
        cell.variableValue.placeholder = String(indexPath.row)
        return cell
    }
    //override to support editing the table view
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            variable.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
    }
}

//extension to UIBarButtonItem , in able to add a GestureRecognizer to it
extension UIBarButtonItem {
    var view: UIView? {
        return value(forKey: "view") as? UIView
    }
    func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if let view = view {
            view.addGestureRecognizer(gestureRecognizer)
            print("Succeed to add GestureRecognizer")
        }
    }
}

