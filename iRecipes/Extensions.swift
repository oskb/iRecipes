//
//  Extensions.swift
//  iRecipes
//
//  Created by Oskar Bævre on 18/10/14.
//  Copyright (c) 2014 123. All rights reserved.
//

import Foundation

extension UIImage
{
    func imageFromColor(color : UIColor, size : CGSize) -> UIImage
    {
        let rect : CGRect = CGRectMake(0, 0, size.width, size.height)
        
        UIGraphicsBeginImageContext(rect.size);
        let context : CGContextRef = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillRect(context, rect);
        
        var image:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func thumbnailFromImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        var newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

extension UIImageView
{
    func loadImageAnimated(animated : Bool, imageData : NSData?)
    {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            
            if let imgData = imageData
            {
                let image = UIImage(data: imgData)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    if animated
                    {
                        self.setImageAnimated(image)
                    }
                    else
                    {
                        self.image = image
                    }
                })
            }
        }
    }
    
    func setImageAnimated(image : UIImage)
    {
        self.alpha = 0.0
        self.image = image
        
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.alpha = 1.0
        })
    }
}

extension CALayer
{
    func starShapeLayer(color : UIColor) -> CAShapeLayer
    {
        var starPath = UIBezierPath()
        starPath.moveToPoint(CGPointMake(self.frame.size.width * 0.15, self.frame.size.height * 0.9))
        starPath.addLineToPoint(CGPointMake(self.frame.size.width * 0.5, 0.2))
        starPath.addLineToPoint(CGPointMake(self.frame.size.width * 0.85, self.frame.size.height * 0.9))
        starPath.addLineToPoint(CGPointMake(0.0, self.frame.size.height * 0.35))
        starPath.addLineToPoint(CGPointMake(self.frame.size.width, self.frame.size.height * 0.35))
        starPath.closePath()
        
        let starShapeLayer = CAShapeLayer()
        starShapeLayer.path = starPath.CGPath
        starShapeLayer.fillColor = color.CGColor
        
        return starShapeLayer
    }
}