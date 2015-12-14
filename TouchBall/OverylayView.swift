//
//  OverylayView.swift
//  TouchBall
//
//  Created by Harvey Zhang on 12/11/15.
//  Copyright © 2015 HappyGuy. All rights reserved.
//

import UIKit

class OverylayView: UIScrollView {
    
    // key point: move scrollview's gesture recognizer to the superview
    // because of the override in the OverlayView (it's not hit testing, so gesture will not work)
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView?
    {
        let sView = super.hitTest(point, withEvent: event)
        
        if sView == self {  // scroll view
            return nil
        }
        
        return sView
    }

}
