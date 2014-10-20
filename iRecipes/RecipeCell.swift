//
//  RecipeCell.swift
//  iRecipes
//
//  Created by Oskar Bævre on 12/10/14.
//  Copyright (c) 2014 123. All rights reserved.
//

import UIKit

class RecipeCell : UITableViewCell
{
    var recipeImageView = ImageView()
    let recipeNameLabel = UILabel()
    let recipeDescriptionLabel = UILabel()
    
    override init()
    {
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    init(reuseIdentifier: String?)
    {
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setupCell()
    }
    
    func setupCell()
    {
        self.contentView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        self.backgroundColor = UIColor.whiteColor()
        
        self.recipeImageView.frame = CGRectMake(0.0, 0.0, 120.0, 120.0)
        self.recipeImageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.contentView.addSubview(self.recipeImageView)
        
        self.recipeNameLabel.frame = CGRectMake(self.recipeImageView.frame.size.width + 10.0, 10.0, self.frame.size.width - 140.0, 30.0)
        self.recipeNameLabel.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin
        self.recipeNameLabel.font = UIFont(name: "AmericanTypeWriter", size: 22.0)
        self.recipeNameLabel.minimumScaleFactor = 0.6
        self.recipeNameLabel.adjustsFontSizeToFitWidth = true
        self.recipeNameLabel.textAlignment = NSTextAlignment.Left
        self.recipeNameLabel.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        self.contentView.addSubview(self.recipeNameLabel)
        
        self.recipeDescriptionLabel.frame = CGRectMake(130.0, 40.0, self.frame.size.width - 140.0, 70.0)
        self.recipeDescriptionLabel.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin
        self.recipeDescriptionLabel.font = UIFont(name: "AmericanTypeWriter", size: 13.0)
        self.recipeDescriptionLabel.numberOfLines = 0
        self.recipeDescriptionLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.recipeDescriptionLabel.textAlignment = NSTextAlignment.Left
        self.recipeDescriptionLabel.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        self.contentView.addSubview(self.recipeDescriptionLabel)
        
        let bottomBorderView = UIView()
        bottomBorderView.frame = CGRectMake(125.0, 119.5, self.frame.size.width - 130.0, 0.5)
        bottomBorderView.backgroundColor = UIColor.lightGrayColor()
        bottomBorderView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        self.contentView.addSubview(bottomBorderView)
    }
}