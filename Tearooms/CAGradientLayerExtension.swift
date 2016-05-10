//
//  CAGradientLayerExtension.swift
//  Tearooms
//
//  Created by Jiří Hroník on 31/03/16.
//  Copyright © 2016 Jiří Hroník. All rights reserved.
//

import Foundation
import QuartzCore
import UIKit

extension CAGradientLayer {
    class func gradientLayerForBounds(bounds: CGRect) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.frame = bounds
        layer.colors = [UIColor.greenColor().CGColor,  UIColor(red: 0, green: 0.7176, blue: 0.3098, alpha: 1.0).CGColor]
        return layer
    }
}