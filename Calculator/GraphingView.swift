//
//  GraphingView.swift
//  Calculator
//
//  Created by 李博文 on 09/12/2017.
//  Copyright © 2017 Nanjing University. All rights reserved.
//

import UIKit

@IBDesignable
class GraphingView: UIView {
    //MARK: Properties
    var origin: CGPoint? {
        didSet {
            setNeedsDisplay()
        }
    }
    var delegate: GraphingViewDelegate?
    @IBInspectable var scale: CGFloat = 50 {
        didSet {
            setNeedsDisplay()
        }
    }
    private var snapshotView: UIView?
    private var axesDrawer = AxesDrawer(color: UIColor.black, contentScaleFactor: 1.0)
    //MARK: Gesture Recognizer handler
    @objc func changeScale(byReactingTo pinchGestureRecognizer: UIPinchGestureRecognizer)
    {
        switch pinchGestureRecognizer.state {
        case .changed:
            scale *= pinchGestureRecognizer.scale
            pinchGestureRecognizer.scale = 1
        default:
            break
        }
    }
    @objc func moveOrigin(byReactingTo panGestureRecognizer: UIPanGestureRecognizer)
    {
        switch panGestureRecognizer.state {
        case .changed:
            origin?.x += panGestureRecognizer.translation(in: self).x
            origin?.y += panGestureRecognizer.translation(in: self).y
            panGestureRecognizer.setTranslation(CGPoint.zero, in: self)
        default:
            break
        }
    }
    @objc func setOrigin(byReactingTo tapGestureRecognizer: UITapGestureRecognizer) {
        origin = tapGestureRecognizer.location(in: self)
    }
    
    //MARK: Private methods
    private func pathOfFunction() -> UIBezierPath
    {
        let path = UIBezierPath()
        var isStartPoint = true
        if let delegate = delegate, let origin = origin {
            let numberOfPixelHorizontally = Int(bounds.width*contentScaleFactor)
            for xPixel in 0...numberOfPixelHorizontally {
                let xValue = (CGFloat(xPixel) - origin.x*contentScaleFactor) / (scale*contentScaleFactor)
                if let yValue = delegate.getYValue(x: xValue) {
                    if yValue.isNormal || yValue.isZero {
                        let yPixel = (origin.y - yValue*scale)*(contentScaleFactor)
                        if isStartPoint {
                            path.move(to: CGPoint(x: CGFloat(xPixel/Int(contentScaleFactor)), y: yPixel/contentScaleFactor))
                            isStartPoint = false
                        }
                        else {
                            path.addLine(to: CGPoint(x: CGFloat(xPixel)/contentScaleFactor, y: yPixel/contentScaleFactor))
                        }
                    }
                    else {
                        isStartPoint = true
                    }
                    
                }
            }
        }
        path.lineWidth = 2.0
        return path
    }
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        if(origin == nil) {
            origin = CGPoint(x: bounds.midX, y: bounds.midY)
        }
            UIColor.red.setStroke()
            pathOfFunction().stroke()
            axesDrawer.contentScaleFactor = contentScaleFactor
            axesDrawer.drawAxes(in: bounds, origin: origin!, pointsPerUnit: scale)
    }
    
}

protocol GraphingViewDelegate {
    func getYValue(x: CGFloat) -> CGFloat?
}
