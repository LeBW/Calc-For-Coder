//
//  VariableTableViewCell.swift
//  Calculator
//
//  Created by 李博文 on 22/12/2017.
//  Copyright © 2017 Nanjing University. All rights reserved.
//

import UIKit

class VariableTableViewCell: UITableViewCell {
    //MARK: Properties
    @IBOutlet weak var variableName: UILabel!
    @IBOutlet weak var variableValue: UITextField!
    
    //MARK: ViewController lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
