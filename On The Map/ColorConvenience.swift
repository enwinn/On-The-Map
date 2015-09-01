//
//  ColorConvenience.swift
//  On The Map
//
//  Created by Eric Winn on 8/2/15.
//  Copyright (c) 2015 Eric N. Winn. All rights reserved.
//

import UIKit

// ATTRIB: - http://stackoverflow.com/a/31124062
// Note: Usage is very clean, easy, and human readable!
//       Here is an example using a 3-step gradient and the RGB (Int) extension:
//            let baseOrange = UIColor(red: 255, green: 127, blue: 0)
//            let lightOrange = UIColor(red: 255, green: 152, blue: 0)
//            let lighterOrange = UIColor(red: 255, green: 177, blue: 0)
//            self.view.layer.configureGradientBackground(baseOrange.CGColor, lightOrange.CGColor, lighterOrange.CGColor)
//       Alternatively (in reverse)
//            self.view.layer.configureGradientBackground(lighterOrange.CGColor, lightOrange.CGColor, baseOrange.CGColor)
extension CALayer {
    
    func configureGradientBackground(colors:CGColorRef...){
        
        let gradient = CAGradientLayer()
        
        let maxWidth = max(self.bounds.size.height,self.bounds.size.width)
        let squareFrame = CGRect(origin: self.bounds.origin, size: CGSizeMake(maxWidth, maxWidth))
        gradient.frame = squareFrame
        
        gradient.colors = colors
        
        self.insertSublayer(gradient, atIndex: 0)
    }
    
}


// ATTRIB: - http://www.codingexplorer.com/create-uicolor-swift/
// NOTE: I've used this RGB "Int" extension to show an alternative but the "Hex" version below is easier to use
//       because many online tools seem to default more to the hex values for colors which then requires 
//       hex to decimal conversion to use this one (either manual or via a function)
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
}

// Using hex inputs is easier to use with tools like the perbang.de RGB Color Gradient Maker http://www.perbang.dk/rgbgradient/
// where you pick a start and end color and the number of gradients steps (3-64) between start and end for a particular gradient configuration.
extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat) {
        let red = CGFloat((hex & 0xFF0000) >> 16)/256.0
        let green = CGFloat((hex & 0xFF00) >> 8)/256.0
        let blue = CGFloat(hex & 0xFF)/256.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
