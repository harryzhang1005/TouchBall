//
//  ViewController.swift
//  TouchBall
//
//  Created by Harvey Zhang on 12/11/15.
//  Copyright © 2015 HappyGuy. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    var canvasView: UIView!
    var scrollView: UIScrollView!
    var drawerView: UIVisualEffectView!
    
    var width: CGFloat {
        return UIScreen.mainScreen().bounds.width
    }
    var height: CGFloat {
        return UIScreen.mainScreen().bounds.height
    }
    
    var drawerHeight: CGFloat {
        
        switch view.traitCollection.userInterfaceIdiom {
        case .Phone:
            return UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation) ? width : height/1.4     // or below line
            //return UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation) ? width : height/1.4
        default:
            return height/1.9
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureViews()
    }

    func configureViews()
    {
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        
        self.canvasView = UIView(frame: rect)
        canvasView.backgroundColor = UIColor.darkGrayColor()
        
        self.scrollView = OverylayView(frame: rect)
        //self.scrollView = UIScrollView(frame: rect)

        self.drawerView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
        
        view.addSubview(canvasView)
        view.addSubview(scrollView)
        scrollView.addSubview(drawerView)
        
        let device = UIDevice.currentDevice().userInterfaceIdiom
        addDotViews(canvasView, count: device == .Pad ? 25 : 10)
        addDotViews(drawerView.contentView, count: device == .Pad ? 20 : 7)
        
        arrangeDotsAndDrawerWithinSize(view.bounds.size)
        
        // key point: move scrollview's gesture recognizer to the superview
        // because of the override in the OverlayView (it's not hit testing, so gesture will not work)
        view.addGestureRecognizer(scrollView.panGestureRecognizer)
        
        // delay touch
        let touchDelay = TouchDelayRecognizer(target: self, action: nil)
        canvasView.addGestureRecognizer(touchDelay)
        
        // show touch indicator
        let touchIndicator = TouchIndicatorRecognizer(target: self, action: nil)
        touchIndicator.delegate = self
        view.addGestureRecognizer(touchIndicator)
    }

    func addDotViews(sView: UIView, count: Int)
    {
        for _ in 0 ..< count
        {
            let fWidth = CGFloat.randomFrameWidth()
            let dot = DotView(frame: CGRect(x: CGFloat.randomX(), y: CGFloat.randomY(), width: fWidth, height: fWidth))
            sView.addSubview(dot)
            
            // add long press gesture recoginzer on dot for grabbing
            let longP = UILongPressGestureRecognizer(target: self, action: Selector("longPressHandler:"))
            longP.cancelsTouchesInView = false  // key point: A boolean value affecting whether touches are delivered to a view when a gesture is recognized.
            longP.delegate = self
            dot.addGestureRecognizer(longP)
        }
    }
    
    func arrangeDotsInView(sView: UIView)
    {
        for dot in sView.subviews
        {
            var newX: CGFloat = 0.0; var newY: CGFloat = 0.0
            
            let w = dot.bounds.width + dot.frame.origin.x
            if w > sView.bounds.width
            {
                newX = w/2
            } else {
                newX = dot.center.x
            }
            
            let h = dot.bounds.height + dot.frame.origin.y
            if h > sView.bounds.height
            {
                newY = h/2
            } else {
                newY = dot.center.y
            }
            
            dot.center = CGPoint(x: newX, y: newY)
        }
    }
    
    /// Handle device changing orientation
    
    // MARK: - Autolayout constraints
    
    /*
    Called when the view controller' view needs to update its constraints.
    
    You may override this method in a subclass in order to add constraints to the view or its subviews. If you override this mehtod, your implementation must invoke super's implementation.
    */
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        let views = ["canvasView": canvasView, "scrollView": scrollView]
        for (_, view) in views {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[canvasView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[canvasView]|", options: [], metrics: nil, views: views))
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[scrollView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[scrollView]|", options: [], metrics: nil, views: views))
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition({ (context) -> Void in
            self.arrangeDotsAndDrawerWithinSize(size)
            }, completion: nil)
    }
    
    func arrangeDotsAndDrawerWithinSize(size: CGSize)
    {
        scrollView.contentSize = CGSize(width: size.width, height: size.height + drawerHeight)
        scrollView.contentOffset = CGPoint(x: 0, y: drawerHeight)
        
        drawerView.frame = CGRect(x: 0, y: 0, width: size.width, height: drawerHeight)
        
        // arrange dot views
        arrangeDotsInView(canvasView)
        arrangeDotsInView(drawerView.contentView)
    }
    
    // MARK: - Handle grab-move and drop dot view
    
    func longPressHandler(longPress: UILongPressGestureRecognizer)
    {
        if let dot = longPress.view
        {
            switch longPress.state {
            case .Began:                grabDot(dot, withGesture: longPress)
            case .Changed:              moveDot(dot, withGesture: longPress)
            case .Ended, .Cancelled:    dropDot(dot, withGesture: longPress)
            default: print("unknown gesture state!")
            }
        }
    }
    
    func grabDot(dot: UIView, withGesture longPress: UIGestureRecognizer)
    {
        dot.center = view.convertPoint(dot.center, fromView: dot.superview)
        view.addSubview(dot)
        
        UIView.animateWithDuration(0.2) { () -> Void in
            dot.transform = CGAffineTransformMakeScale(1.2, 1.2)
            dot.alpha = 0.75
            self.moveDot(dot, withGesture: longPress)   // to avoid jump issue at first
        }
        
        // disable and re-enable scrollview's pan gesture recognizer so the drawer can't be opened with moving the dot view
        // disabling will cause it to stop tracking all the touches which it was tracking (including the long press)
        // re-enabling will allow it to be ready to track new touches that might start
        scrollView.panGestureRecognizer.enabled = false
        scrollView.panGestureRecognizer.enabled = true
    }
    
    func moveDot(dot: UIView, withGesture longPress: UIGestureRecognizer)
    {
        dot.center = longPress.locationInView(view)
    }
    
    func dropDot(dot: UIView, withGesture longPress: UIGestureRecognizer)
    {
        UIView.animateWithDuration(0.2) { () -> Void in
            dot.transform = CGAffineTransformIdentity
            dot.alpha = 1.0
        }
        
        let pInDrawer = longPress.locationInView(drawerView)
        if CGRectContainsPoint(drawerView.bounds, pInDrawer) {
            drawerView.contentView.addSubview(dot)
        } else {
            canvasView.addSubview(dot)
        }
        dot.center = view.convertPoint(dot.center, toView: dot.superview)
    }


}

extension ViewController: UIGestureRecognizerDelegate
{
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        // we should be specific here because it's easy source of bugs
        // but in this example we do want that all of the gestures (long press, pan, indicator) to work simultaneously
        // so it's possible to move the dots with multiple fingers, and open drawer with other finger at the same time

        return true
    }
    
}

