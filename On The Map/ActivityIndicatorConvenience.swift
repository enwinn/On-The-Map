//
//  ActivityIndicatorConvenience.swift
//  On The Map
//
//  Created by Eric Winn on 8/22/15.
//  Copyright (c) 2015 Eric N. Winn. All rights reserved.
//

import UIKit

public class ActivityIndicatorView {
    
    var containerView = UIView()
    var indicatorView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    public class var shared: ActivityIndicatorView {
        struct Static {
            static let instance: ActivityIndicatorView = ActivityIndicatorView()
        }
        return Static.instance
    }
    
    public func showActivityIndicator(view: UIView) {
        println("AI show: called")
        containerView.frame = view.frame
        containerView.center = view.center
        containerView.backgroundColor = UIColor(hex: 0xffffffff, alpha: 0.4)
        
        indicatorView.frame = CGRectMake(0, 0, 80, 80)
        indicatorView.center = view.center
        // Configure background gradient
        // useful in designing color gradients by defining 2 end colors and the number of steps between: http://www.perbang.dk/rgbgradient/
        // using 3 steps (hex):
//        let lightBlue = UIColor(hex: 0x0072fa, alpha: 0.8)
//        let lighterBlue = UIColor(hex: 0x3590fc, alpha: 0.8)
//        let lightestBlue = UIColor(hex: 0x6bafff, alpha: 0.8)
//        indicatorView.layer.configureGradientBackground(lightBlue.CGColor, lighterBlue.CGColor, lightestBlue.CGColor)
        // using 3 steps (hex)
        let baseOrange = UIColor(hex: 0xff7f00, alpha: 1.0)
        let lightOrange = UIColor(hex: 0xff9800, alpha: 1.0)
        let lighterOrange = UIColor(hex: 0xffb100, alpha: 1.0)
        indicatorView.layer.configureGradientBackground(baseOrange.CGColor, lightOrange.CGColor, lighterOrange.CGColor)
        indicatorView.clipsToBounds = true
        indicatorView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRectMake(0, 0, 40, 40)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.center = CGPointMake(indicatorView.bounds.width / 2, indicatorView.bounds.height / 2)
        
        indicatorView.addSubview(activityIndicator)
        containerView.addSubview(indicatorView)
        view.addSubview(containerView)
        
        activityIndicator.startAnimating()
    }
    
    public func hideActivityIndicatorView() {
        println("AI hide: called")
        activityIndicator.stopAnimating()
        containerView.removeFromSuperview()
    }
}
