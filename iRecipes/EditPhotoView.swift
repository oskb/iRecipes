//
//  EditPhotoView.swift
//  iRecipes
//
//  Created by Oskar Bævre on 18/10/14.
//  Copyright (c) 2014 123. All rights reserved.
//

import UIKit

class EditPhotoView : BaseEditView
{
    let imageView = ImageView()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.addNameLabel("Photo:")
        self.addImageView()
    }
 
    private func addImageView()
    {
        self.imageView.frame = CGRectMake(0.0, 80.0, self.frame.size.width, self.frame.size.height - 80.0)
        self.imageView.userInteractionEnabled = true
        
        self.addSubview(self.imageView)
    }
    
    func startImageLoadingIndicator()
    {
        self.imageView.startImageLoadingIndicator()
    }
    
    func stopImageLoadingIndicatorAndLoadImageAnimated(imageData: NSData?)
    {
        self.imageView.stopImageLoadingIndicator()
        self.imageView.image = nil
        self.loadImageAnimated(imageData)
    }
    
    func loadImageAnimated(imageData: NSData?)
    {
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.imageView.loadImageAnimated(true, imageData: imageData)
    }
    
    func setImage(image : UIImage)
    {
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.imageView.image = image
    }
    
    func image() -> UIImage?
    {
        return self.imageView.image
    }
    
    func showPlaceholderImage()
    {
        if !self.imageView.isImageLoadingIndicatorAnimating()
        {
            self.imageView.contentMode = UIViewContentMode.Center
            self.imageView.image = UIImage(named: "camera_placeholder.png")
        }
    }
}