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
    //初始化每一个ViewController
    var adVancedViewController: AdvancedViewController!
    var hexViewController: HexViewController!
    var equationNavigationViewController: EquationNavigationViewController!
    var statisticsViewController: UINavigationController!
    var graphCalculatorViewController: UINavigationController!
    //TODO...
    
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
    private func initAllCalculatorViewController()
    {
        adVancedViewController = UIStoryboard.advancedViewController()
        hexViewController = UIStoryboard.hexViewController()
        equationNavigationViewController = UIStoryboard.equationNavigationViewController()
        statisticsViewController = UIStoryboard.statisticsViewController()
        graphCalculatorViewController = UIStoryboard.graphCalculatorViewController()
        
        adVancedViewController.view.addGestureRecognizer(setPanGestureRecognizer())
        hexViewController.view.addGestureRecognizer(setPanGestureRecognizer())
        //equationNavigationViewController.visibleViewController?.view.addGestureRecognizer(setPanGestureRecognizer())
        //graphCalculatorViewController.visibleViewController?.view.addGestureRecognizer(setPanGestureRecognizer())
        //需要特殊处理的几个ViewController。因为手势所在的view和手势要处理的view不是一个
        let equationPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleEquationPanGesture))
        equationNavigationViewController.visibleViewController?.view.addGestureRecognizer(equationPanGestureRecognizer)
        
        let graphPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleGraphPanGesture(_:)))
        graphCalculatorViewController.visibleViewController?.view.addGestureRecognizer(graphPanGestureRecognizer)
        
        let statisticsGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleStatisticsPanGesture))
        statisticsGestureRecognizer.cancelsTouchesInView = false
        statisticsViewController.visibleViewController?.view.addGestureRecognizer(statisticsGestureRecognizer)
        //TODO...
        //除了第一个viewController外，其余的view初始应该在中间处
        adVancedViewController.view.center.x += targetPositionX
        equationNavigationViewController.view.center.x += targetPositionX
        statisticsViewController.view.center.x += targetPositionX
        graphCalculatorViewController.view.center.x += targetPositionX
    }
    private func setPanGestureRecognizer() -> UIPanGestureRecognizer
    {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        return panGestureRecognizer
    }
    private func setCenterViewController(willbe centerViewController: UIViewController)
    {
        self.centerViewController = centerViewController
        
        view.addSubview(centerViewController.view)
        addChildViewController(centerViewController)
        centerViewController.didMove(toParentViewController: self)
    }
    private func changeCenterViewController(to centerViewController: UIViewController)
    {
        self.centerViewController = centerViewController
        
    }
    //MARK: Slide Out implement methods
    
    
    func addLeftPanelViewController()
    {
        guard leftViewController == nil else {return }
        if let vc = UIStoryboard.leftViewController() {
            addChildSidePanelController(vc)
            leftViewController = vc
            leftViewController?.delegate = self
        }
    }
    func addChildSidePanelController(_ sidePanelController: SidePanelViewController)
    {
        view.insertSubview(sidePanelController.view, at: 0)
        
        addChildViewController(sidePanelController)
        sidePanelController.didMove(toParentViewController: self)
    }
    
    func showShadowForCenterViewController(_ shouldShowShadow: Bool)
    {
        if shouldShowShadow {
            centerViewController.view.layer.shadowOpacity = 0.8
        }
        else {
            centerViewController.view.layer.shadowOpacity = 0
        }
    }
    func animateLeftPanel(shouldExpanded: Bool)
    {
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
    func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)? = nil)
    {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {self.centerViewController.view.frame.origin.x = targetPosition}, completion: completion)
    }
}

//MARK: Extension
extension ContainerViewController: UIGestureRecognizerDelegate
{
    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer)
    {
        //let gestureIsDraggingFromLeftToRight = (recognizer.velocity(in: view).x > 0)
        
        switch recognizer.state {
        case .began:
            showShadowForCenterViewController(true)
        case .changed:
            if let rview = recognizer.view {
                rview.center.x = rview.center.x +  recognizer.translation(in: view).x
                if(rview.center.x < view.bounds.midX) {
                    rview.center.x = view.bounds.midX
                }
                else if(rview.center.x > view.bounds.midX + targetPositionX) {
                    rview.center.x = view.bounds.midX + targetPositionX
                }
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
    @objc func handleEquationPanGesture(_ recognizer: UIPanGestureRecognizer)
    {
        switch recognizer.state
        {
        case .began:
            showShadowForCenterViewController(true)
        case .changed:
            if let rview = equationNavigationViewController.view {
                rview.center.x = rview.center.x +  recognizer.translation(in: view).x
                if(rview.center.x < view.bounds.midX) {
                    rview.center.x = view.bounds.midX
                }
                else if(rview.center.x > view.bounds.midX + targetPositionX) {
                    rview.center.x = view.bounds.midX + targetPositionX
                }
                recognizer.setTranslation(CGPoint.zero, in: view)
            }
        case .ended:
            if let rview = equationNavigationViewController.view {
                let hasMoveHalfway = ((rview.center.x - view.bounds.midX) > targetPositionX / 2)
                animateLeftPanel(shouldExpanded: hasMoveHalfway)
            }
        default:
            break
        }
    }
    @objc func handleGraphPanGesture(_ recognizer: UIPanGestureRecognizer)
    {
        switch recognizer.state {
        case .began:
            showShadowForCenterViewController(true)
        case .changed:
            if let rview = graphCalculatorViewController.view {
                rview.center.x = rview.center.x +  recognizer.translation(in: view).x
                if(rview.center.x < view.bounds.midX) {
                    rview.center.x = view.bounds.midX
                }
                else if(rview.center.x > view.bounds.midX + targetPositionX) {
                    rview.center.x = view.bounds.midX + targetPositionX
                }
                recognizer.setTranslation(CGPoint.zero, in: view)
            }
        case .ended:
            if let rview = graphCalculatorViewController.view {
                let hasMoveHalfway = ((rview.center.x - view.bounds.midX) > targetPositionX / 2)
                animateLeftPanel(shouldExpanded: hasMoveHalfway)
            }
        default:
            break
        }
    }
    @objc func handleStatisticsPanGesture(_ recognizer: UIPanGestureRecognizer)
    {
        switch recognizer.state {
        case .began:
            showShadowForCenterViewController(true)
            if let statisticsViewController = statisticsViewController.visibleViewController as? StatisticsViewController {
                if let activeField = statisticsViewController.activeTextField {
                    if activeField.isFirstResponder {
                        activeField.resignFirstResponder()
                    }
                }
            }
        case .changed:
            if let rview = statisticsViewController.view {
                rview.center.x = rview.center.x +  recognizer.translation(in: view).x
                if(rview.center.x < view.bounds.midX) {
                    rview.center.x = view.bounds.midX
                }
                else if(rview.center.x > view.bounds.midX + targetPositionX) {
                    rview.center.x = view.bounds.midX + targetPositionX
                }
                recognizer.setTranslation(CGPoint.zero, in: view)
            }
        case .ended:
            if let rview = statisticsViewController.view {
                let hasMoveHalfway = ((rview.center.x - view.bounds.midX) > targetPositionX / 2)
                animateLeftPanel(shouldExpanded: hasMoveHalfway)
            }
        default:
            break
        }
    }
    
}

extension ContainerViewController: SidePanelViewControllerDelegate {
    func hexTapped()
    {
        //centerViewController change.
        setCenterViewController(willbe: hexViewController)
        animateLeftPanel(shouldExpanded: false)
    }
    func advancedTapped()
    {
        setCenterViewController(willbe: adVancedViewController)
        animateLeftPanel(shouldExpanded: false)
    }
    func equationTapped()
    {
        setCenterViewController(willbe: equationNavigationViewController)
        animateLeftPanel(shouldExpanded: false)
    }
    func statisticsTapped()
    {
        setCenterViewController(willbe: statisticsViewController)
        animateLeftPanel(shouldExpanded: false)
    }
    func drawTapped()
    {
        setCenterViewController(willbe: graphCalculatorViewController)
        animateLeftPanel(shouldExpanded: false)
    }
}

extension UIStoryboard {
    static func mainStoryboard() -> UIStoryboard
    {
        return UIStoryboard(name: "Main", bundle: Bundle.main)
    }
    static func advancedViewController() -> AdvancedViewController?
    {
        return mainStoryboard().instantiateViewController(withIdentifier: "AdvancedViewController") as? AdvancedViewController
    }
    static func leftViewController() -> SidePanelViewController?
    {
        return mainStoryboard().instantiateViewController(withIdentifier: "LeftViewController") as? SidePanelViewController
    }
    static func hexViewController() -> HexViewController?
    {
        return mainStoryboard().instantiateViewController(withIdentifier: "HexViewController") as? HexViewController
    }
    static func equationNavigationViewController() -> EquationNavigationViewController?
    {
        return mainStoryboard().instantiateViewController(withIdentifier: "EquationNavigationViewController") as? EquationNavigationViewController
    }
    static func statisticsViewController() -> UINavigationController?
    {
        return mainStoryboard().instantiateViewController(withIdentifier: "StatisticsViewController") as? UINavigationController
    }
    static func graphCalculatorViewController() -> UINavigationController?
    {
        return mainStoryboard().instantiateViewController(withIdentifier: "GraphCalculatorViewController") as? UINavigationController
    }
}
