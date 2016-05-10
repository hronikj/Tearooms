//
//  NavigationController.swift
//  Tearooms
//
//  Created by Jiří Hroník on 31/03/16.
//  Copyright © 2016 Jiří Hroník. All rights reserved.
//

import Foundation
import UIKit

class NavigationController: UINavigationController {
    private func imageLayerForGradientBackground() -> UIImage {
        var updatedFrame = self.navigationBar.bounds
        updatedFrame.size.height += 20 // take into account the status bar
        
        let layer = CAGradientLayer.gradientLayerForBounds(updatedFrame)
        
        UIGraphicsBeginImageContext(layer.bounds.size)
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().statusBarStyle = .Default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let barsColor = UIColor(red: 0.43, green: 0.77, blue: 0.14, alpha: 0.7)
        // let barsColor = UIColor(red:0.60, green:0.84, blue:0.40, alpha:1.00)
        
        // add colored view to the top
        let statusBarView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 20))
        statusBarView.backgroundColor = barsColor
        self.view.addSubview(statusBarView)
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        self.navigationBar.translucent = true
        self.navigationBar.tintColor = UIColor.whiteColor()
        let fontDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationBar.titleTextAttributes = fontDictionary
        
        // self.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), forBarMetrics: UIBarMetrics.Default)
        self.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.backgroundColor = barsColor
    }
}