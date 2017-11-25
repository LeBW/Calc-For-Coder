//
//  ContainerViewController.swift
//  Calculator
//
//  Created by 李博文 on 2017/11/23.
//  Copyright © 2017年 Nanjing University. All rights reserved.
//

import UIKit
import QuartzCore

class ContainerViewController: UIViewController {
    //MARK: Inner classes or enumurations
    enum SlideOutState {
        case collapsed
        case leftPanelExpanded
    }
    //MARK: Properties
    var targetPositionX: CGFloat = 180   //滑动后centerView的x值
    
    var centerViewController: UIViewController!  //显示在屏幕上的viewController
    var leftViewController: SidePanelViewController? //左边滑动出现的viewController
    
    var currentState: SlideOutState = .collapsed
    
    var adVancedViewController: AdvancedViewController!
    var hexViewController: HexViewController!
    
    //MARK: UI methods
    override func viewDidLoad() {
        super.viewDidLoad()
        initAllCalculatorViewController()
        addLeftPanelViewController()
        setCenterViewController(willbe: hexViewController)
        /*add gesture recognizer
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        centerViewController.view.addGestureRecognizer(panGestureRecognizer)
         */
    }
    //MARK: Private mathods
    private func initAllCalculatorViewController() {
        adVancedViewController = UIStoryboard.advancedViewController()
        hexViewController = UIStoryboard.hexViewController()
        adVancedViewController.view.addGestureRecognizer(setPanGestureRecognizer())
        hexViewController.view.addGestureRecognizer(setPanGestureRecognizer())
        
        //除了第一个viewController外，其余的view初始应该在中间处
        adVancedViewController.view.center.x += targetPositionX
    }
    private func setPanGestureRecognizer() -> UIPanGestureRecognizer{
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        return panGestureRecognizer
    }
    private func setCenterViewController(willbe centerViewController: UIViewController) {
        self.centerViewController = centerViewController
        
        view.addSubview(centerViewController.view)
        addChildViewController(centerViewController)
        centerViewController.didMove(toParentViewController: self)
    }
    private func changeCenterViewController(to centerViewController: UIViewController) {
        self.centerViewController = centerViewController
        
    }
    //MARK: Slide Out implement methods
    
    
    func addLeftPanelViewController() {
        guard leftViewController == nil else {return }
        if let vc = UIStoryboard.leftViewController() {
            addChildSidePanelController(vc)
            leftViewController = vc
            leftViewController?.delegate = self
        }
    }
    func addChildSidePanelController(_ sidePanelController: SidePanelViewController) {
        view.insertSubview(sidePanelController.view, at: 0)
        
        addChildViewController(sidePanelController)
        sidePanelController.didMove(toParentViewController: self)
    }
    
    func showShadowForCenterViewController(_ shouldShowShadow: Bool) {
        if shouldShowShadow {
            centerViewController.view.layer.shadowOpacity = 0.8
        }
        else {
            centerViewController.view.layer.shadowOpacity = 0
        }
    }
    func animateLeftPanel(shouldExpanded: Bool) {
        if shouldExpanded {
            currentState = .leftPanelExpanded
            animateCenterPanelXPosition(targetPosition: targetPositionX)
        }
        else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.currentState = .collapsed
                //self.leftViewController?.view.removeFromSuperview()
                //self.leftViewController = nil
            }
        }
    }
    func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {self.centerViewController.view.frame.origin.x = targetPosition}, completion: completion)
    }
}

//MARK: Extension
extension ContainerViewController: UIGestureRecognizerDelegate {
    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        //let gestureIsDraggingFromLeftToRight = (recognizer.velocity(in: view).x > 0)
        
        switch recognizer.state {
        case .began:
            
            showShadowForCenterViewController(true)
        case .changed:
            if let rview = recognizer.view {
                rview.center.x = rview.center.x +  recognizer.translation(in: view).x
                recognizer.setTranslation(CGPoint.zero, in: view)
            }
        case .ended:
            if let rview = recognizer.view {
                let hasMoveHalfway = ((rview.center.x - view.bounds.midX) > targetPositionX / 2)
                animateLeftPanel(shouldExpanded: hasMoveHalfway)
            }
        default:
            break
        }
    }
    
}

extension ContainerViewController: SidePanelViewControllerDelegate {
    func hexTapped() {
        //centerViewController change.
        setCenterViewController(willbe: hexViewController)
        animateLeftPanel(shouldExpanded: false)
    }
    func advancedTapped() {
        setCenterViewController(willbe: adVancedViewController)
        animateLeftPanel(shouldExpanded: false)
    }
}

extension UIStoryboard {
    static func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: Bundle.main)
    }
    static func advancedViewController() -> AdvancedViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "AdvancedViewController") as? AdvancedViewController
    }
    static func leftViewController() -> SidePanelViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "LeftViewController") as? SidePanelViewController
    }
    static func hexViewController() -> HexViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "HexViewController") as? HexViewController
    }
}
