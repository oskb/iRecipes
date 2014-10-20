//
//  FavoriteStarView.swift
//  iRecipes
//
//  Created by Oskar Bævre on 17/10/14.
//  Copyright (c) 2014 123. All rights reserved.
//

import UIKit

class FavoriteStarView : UIView
{
    private var starLayer : CALayer?
    
    init(frame: CGRect, starColor : UIColor)
    {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
        self.starLayer = self.layer.starShapeLayer(starColor)
        self.layer.addSublayer(self.starLayer!)
        self.layer.zPosition = 20
        self.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }

    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func rotateStarAndSetNewColor(color : UIColor)
    {
        let rotationDegrees = self.degreesToRadians(180.0)
        var rotatedAndScaledTransform = CATransform3DIdentity
        rotatedAndScaledTransform.m34 = -0.005
        rotatedAndScaledTransform = CATransform3DRotate(rotatedAndScaledTransform, rotationDegrees, 0, 1, 0)
        rotatedAndScaledTransform = CATransform3DScale(rotatedAndScaledTransform, 1.8, 1.8, 1.8)
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            
            self.layer.transform = rotatedAndScaledTransform
            
            }) { (Bool) -> Void in
                
                self.replaceStarLayerAndSetColor(color, transform: rotatedAndScaledTransform)
                
                UIView.animateWithDuration(0.4, animations: { () -> Void in
                    
                    self.layer.transform = CATransform3DIdentity
                })
        }
    }

    private func replaceStarLayerAndSetColor(color : UIColor, transform : CATransform3D)
    {
        self.starLayer?.removeFromSuperlayer()
        self.layer.transform = CATransform3DIdentity
        
        self.starLayer = self.layer.starShapeLayer(color)
        self.layer.addSublayer(self.starLayer!)
        self.layer.transform = transform
    }
    
    private func degreesToRadians(degrees : Double) -> CGFloat
    {
        return CGFloat(degrees * M_PI / Double(180.0))
    }
}
