//
//  SidePanelViewController.swift
//  Calculator
//
//  Created by 李博文 on 2017/11/23.
//  Copyright © 2017年 Nanjing University. All rights reserved.
//

import UIKit

class SidePanelViewController: UIViewController {

    var delegate: SidePanelViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func hexTapped(_ sender: UIButton) {
        delegate?.hexTapped?()
    }
    
    @IBAction func advancedTapped(_ sender: UIButton) {
        delegate?.advancedTapped?()
    }
    
    @IBAction func statisticsTapped(_ sender: UIButton) {
        delegate?.statisticsTapped?()
    }
    
    @IBAction func drawTapped(_ sender: UIButton) {
        delegate?.drawTapped?()
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

@objc
protocol SidePanelViewControllerDelegate {
    @objc optional func hexTapped()
    @objc optional func advancedTapped()
    @objc optional func statisticsTapped()
    @objc optional func drawTapped()
}
