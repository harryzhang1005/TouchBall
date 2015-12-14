//
//  TouchIndicatorRecognizer.swift
//  TouchBall
//
//  Created by Harvey Zhang on 12/14/15.
//  Copyright © 2015 HappyGuy. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass        // required for touches handler

class TouchIndicatorRecognizer: UIGestureRecognizer
{
    var activeTouches = [UITouch: UIView]()
    
    override init(target: AnyObject?, action: Selector) {
        super.init(target: target, action: action)
        
        // default is YES. causes touchesCancelled:withEvent: or pressesCancelled:withEvent: to be sent to the view for all touches or presses recognized as part of this gesture immediately before the action method is called.
        // key point: A boolean value affecting whether touches are delivered to a view when a gesture is recognized.
        cancelsTouchesInView = false
    }
    
    // MARK: - Helpers
    
    class func CreateTouchIndicator() -> UIView
    {
        let ti = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        ti.layer.cornerRadius = 10
        ti.backgroundColor = UIColor.whiteColor()
        ti.alpha = 0.8
        
        return ti
    }
    
    func createIndicatorView(touch: UITouch)
    {
        state = .Began
        
        let indicator = TouchIndicatorRecognizer.CreateTouchIndicator()
        indicator.center = touch.locationInView(self.view)
        indicator.transform = CGAffineTransformMakeScale(0.01, 0.01)
        indicator.layer.zPosition = CGFloat(MAXFLOAT)       // key point: put to top
        
        if let gestureView = view {
            gestureView.addSubview(indicator)
            activeTouches[touch] = indicator
        }
        
        // back scale to normal
        UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                indicator.transform = CGAffineTransformIdentity
            }, completion: nil)
    }
    
    func moveIndicatorView(touch: UITouch)
    {
        if let v = activeTouches[touch] {
            v.center = touch.locationInView(self.view)
            state = .Changed
        }
    }
    
    func removeIndicatorView(touch: UITouch)
    {
        if let v = activeTouches[touch]
        {
            UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .AllowUserInteraction, animations: { () -> Void in
                    v.transform = CGAffineTransformMakeScale(0.01, 0.01)
                }, completion: { (finished) -> Void in
                    v.removeFromSuperview()
                    self.activeTouches.removeValueForKey(touch)
                    if self.activeTouches.count == 0 {
                        self.state = .Ended
                    }
            })
        }
    }
    
    // MARK: - Extension Gesture Recognizer methods
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        
        // create an touch indicator views
        for touch in touches {
            createIndicatorView(touch)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        
        for touch in touches {
            moveIndicatorView(touch)
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesCancelled(touches, withEvent: event)
        
        for touch in touches {
            removeIndicatorView(touch)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        
        for touch in touches {
            removeIndicatorView(touch)
        }
    }

}
