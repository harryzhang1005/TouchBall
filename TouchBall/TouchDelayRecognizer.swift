//
//  TouchDelayRecognizer.swift
//  TouchBall
//
//  Created by Harvey Zhang on 12/14/15.
//  Copyright © 2015 HappyGuy. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class TouchDelayRecognizer: UIGestureRecognizer
{
    var timer: NSTimer?
    
    override init(target: AnyObject?, action: Selector) {
        super.init(target: target, action: action)
        
        // A boolean value determing whether the receiver delays sending touches in a begin phase to its view
        delaysTouchesBegan = true
    }
    
    // Overridden to reset internal state when a gesture recognition attempt completes.
    override func reset() {
        timer?.invalidate()
        timer = nil
    }
    
    func fail() {
        state = .Failed
    }
    
    // MARK: - Overrides
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.15, target: self, selector: Selector("fail"), userInfo: nil, repeats: false)
    }
    
    override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesCancelled(touches, withEvent: event)
        fail()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        fail()
    }

}
