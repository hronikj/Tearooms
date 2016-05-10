//
//  SplashScreenViewController.swift
//  Tearooms
//
//  Created by Jiří Hroník on 30/03/16.
//  Copyright © 2016 Jiří Hroník. All rights reserved.
//

import Foundation
import UIKit

class SplashScreenViewController: UIViewController {
    @IBOutlet weak var image: UIImageView!
    let applyBlur = false
    
    override func viewDidLoad() {
        self.image.image = UIImage(named: "SplashScreen")
        self.image.layer.borderWidth = 1.0
        self.image.layer.borderColor = UIColor.whiteColor().CGColor
        self.image.layer.cornerRadius = 13
        self.image.layer.cornerRadius = image.frame.size.height / 2
        self.image.contentMode = UIViewContentMode.ScaleAspectFill
        self.image.clipsToBounds = true
        
        if applyBlur {
            // blur effect
            let blurEffect = UIBlurEffect(style: .Light)
            let blurredEffectView = UIVisualEffectView(effect: blurEffect)
            blurredEffectView.frame = self.image.bounds
            self.image.addSubview(blurredEffectView)
            
            // vibrancy effect
            let vibrancyEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
            let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
            vibrancyEffectView.frame = self.image.bounds
            
            blurredEffectView.contentView.addSubview(vibrancyEffectView)
        }
        
        bounceImage()
    }
    
    func bounceImage() {
        let expandTransform: CGAffineTransform = CGAffineTransformMakeScale(2, 2)
        UIView.animateWithDuration(1, delay: 0.2, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.2, options: .CurveEaseOut, animations: {
            self.image.transform = CGAffineTransformInvert(expandTransform)
            }, completion: {
                (Bool) in
                self.performSegueWithIdentifier("SplashScreenSegueIdentifier", sender: nil)
        })
    }
    
}