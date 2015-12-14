//
//  DotView.swift
//  TouchBall
//
//  Created by Harvey Zhang on 12/11/15.
//  Copyright © 2015 HappyGuy. All rights reserved.
//

import UIKit

class DotView: UIView
{
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.randomColor
        self.layer.cornerRadius = frame.height/2
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Extensions

private extension UIColor {
    class var randomColor: UIColor {
        switch random()%5 {
        case 0: return UIColor.redColor()
        case 1: return UIColor.greenColor()
        case 2: return UIColor.blueColor()
        case 3: return UIColor.orangeColor()
        case 4: return UIColor.yellowColor()
        default: return UIColor.darkGrayColor()
        }
    }
}

extension CGFloat {
    static func randomFrameWidth() -> CGFloat
    {
        return CGFloat(random()%100) + 10.0
    }
    
    static func randomX() -> CGFloat {
        let w = UIScreen.mainScreen().bounds.width - 40.0
        return CGFloat(random())%w + 20.0
    }
    
    static func randomY() -> CGFloat {
        let h = UIScreen.mainScreen().bounds.height - 40.0
        return CGFloat(random())%h + 20.0
    }
}
