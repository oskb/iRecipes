//
//  BaseEditView.swift
//  iRecipes
//
//  Created by Oskar Bævre on 18/10/14.
//  Copyright (c) 2014 123. All rights reserved.
//

import UIKit

class BaseEditView : UIView
{
    let nameLabel = UILabel()
    private let nameLabelFont = UIFont(name: "AmericanTypeWriter", size: 36.0)
    
    func addNameLabel(name : String)
    {
        nameLabel.frame = CGRectMake(0.0, 20.0, self.frame.size.width, 50.0)
        nameLabel.font = self.nameLabelFont
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.textAlignment = NSTextAlignment.Center
        nameLabel.text = name
        
        self.addSubview(nameLabel)
    }
}
