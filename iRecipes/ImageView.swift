//
//  ImageView.swift
//  iRecipes
//
//  Created by Oskar Bævre on 18/10/14.
//  Copyright (c) 2014 123. All rights reserved.
//

import UIKit

class ImageView : UIImageView
{
    private let imageLoadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    override init()
    {
        super.init()
        self.addImageLoadingIndicator()
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.addImageLoadingIndicator()
    }

    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var frame : CGRect
    {
        get {
            return super.frame
        }
        set {
            super.frame = newValue
            self.centerImageLoadingIndicator()
        }
    }
    
    private func centerImageLoadingIndicator()
    {
        self.imageLoadingIndicator.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
    }
    
    private func addImageLoadingIndicator()
    {
        self.clipsToBounds = true
        self.imageLoadingIndicator.frame = CGRectMake(0.0, 0.0, 60.0, 60.0)
        self.imageLoadingIndicator.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
        self.imageLoadingIndicator.color = UIColor.redColor()
        self.imageLoadingIndicator.hidesWhenStopped = true
        self.addSubview(self.imageLoadingIndicator)
    }
    
    func startImageLoadingIndicator()
    {
        self.imageLoadingIndicator.startAnimating()
    }
    
    func stopImageLoadingIndicator()
    {
        self.imageLoadingIndicator.stopAnimating()
    }
    
    func isImageLoadingIndicatorAnimating() -> Bool
    {
        return self.imageLoadingIndicator.isAnimating()
    }
}