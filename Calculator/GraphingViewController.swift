//
//  GraphingViewController.swift
//  Calculator
//
//  Created by 李博文 on 09/12/2017.
//  Copyright © 2017 Nanjing University. All rights reserved.
//

import UIKit

class GraphingViewController: UIViewController {

    //Properties
    var unaryFunction: ((Double) -> Double?)?  //由x计算y的函数
    
    @IBOutlet weak var graphingView: GraphingView!
    
    //ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        graphingView.delegate = self
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: graphingView, action: #selector(graphingView.moveOrigin(byReactingTo:)))
        graphingView.addGestureRecognizer(panGestureRecognizer)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideNavigationBar))
        graphingView.addGestureRecognizer(tapGestureRecognizer)
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: graphingView, action: #selector(graphingView.setOrigin))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        graphingView.addGestureRecognizer(doubleTapGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: graphingView, action: #selector(graphingView.changeScale(byReactingTo:)))
        graphingView.addGestureRecognizer(pinchGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Private methods
    @objc func hideNavigationBar(byReactingTo tapGestureRecognizer: UITapGestureRecognizer)
    {
        if let navigationController = self.navigationController {
            if navigationController.isNavigationBarHidden {
                navigationController.setNavigationBarHidden(false, animated: true)
            }
            else {
                navigationController.setNavigationBarHidden(true, animated: true)
            }
        }
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
extension GraphingViewController: GraphingViewDelegate
{
    
    func getYValue(x: CGFloat) -> CGFloat? {
        if let yValue = unaryFunction?(Double(x)) {
            return CGFloat(yValue)
        }
        return nil
    }
    
}
