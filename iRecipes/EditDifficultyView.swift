//
//  EditDifficultyView.swift
//  iRecipes
//
//  Created by Oskar Bævre on 18/10/14.
//  Copyright (c) 2014 123. All rights reserved.
//

import UIKit

protocol EditDifficultViewDelegate
{
    func difficultyChanged(difficulty : Int)
}

class EditDifficultyView : BaseEditView
{
    var difficulty1Button = UIButton()
    var difficulty2Button = UIButton()
    var difficulty3Button = UIButton()
    var delegate : EditDifficultViewDelegate?
    
    private let buttonTitleFont = UIFont(name: "AmericanTypeWriter", size: 40.0)
    
    init(frame: CGRect, delegate: EditDifficultViewDelegate)
    {
        super.init(frame: frame)
        self.delegate = delegate
        self.setup(frame)
    }
    
    func setup(frame : CGRect)
    {
        self.backgroundColor = UIColor.whiteColor()
        self.addNameLabel("Difficulty:")
        
        self.addDifficulty1Button()
        self.addDifficulty2Button()
        self.addDifficulty3Button()
    }
    
    private func addDifficulty1Button()
    {
        self.difficulty1Button = createDifficultyButton(CGRectMake(self.frame.size.width/4 - 60.0, self.frame.size.height/2 - 20, 80.0, 80.0))
        self.difficulty1Button.setTitle("1", forState: UIControlState.Normal)
        self.difficulty1Button.tag = 1
        self.addSubview(self.difficulty1Button)
    }
    
    private func addDifficulty2Button()
    {
        self.difficulty2Button = createDifficultyButton(CGRectMake(self.frame.size.width/2 - 40.0, self.frame.size.height/2 - 20, 80.0, 80.0))
        self.difficulty2Button.setTitle("2", forState: UIControlState.Normal)
        self.difficulty2Button.tag = 2
        self.addSubview(self.difficulty2Button)
    }
    
    private func addDifficulty3Button()
    {
        self.difficulty3Button = createDifficultyButton(CGRectMake(self.frame.size.width - self.frame.size.width/4 - 20.0, self.frame.size.height/2 - 20, 80.0, 80.0))
        self.difficulty3Button.setTitle("3", forState: UIControlState.Normal)
        self.difficulty3Button.tag = 3
        self.addSubview(self.difficulty3Button)
    }
    
    private func createDifficultyButton(frame: CGRect) -> UIButton
    {
        let button = UIButton(frame: frame)
        button.setTitleColor(button.tintColor!, forState: UIControlState.Normal)
        button.setBackgroundImage(nil, forState: UIControlState.Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        button.setBackgroundImage(UIImage().imageFromColor(button.tintColor!, size: button.frame.size), forState: UIControlState.Selected)
        button.titleLabel?.font = self.buttonTitleFont
        button.layer.borderColor = button.tintColor?.CGColor
        button.layer.borderWidth = 1.5
        
        button.addTarget(self, action: "buttonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        
        return button
    }
    
    private func buttonsInSubViews() -> [UIButton]
    {
        var buttonArray = Array<UIButton>()
        
        for view in self.subviews
        {
            if view.isKindOfClass(UIButton)
            {
                buttonArray.append(view as UIButton)
            }
        }
        
        return buttonArray
    }
    
    func buttonTapped(button : UIButton)
    {
        if !button.selected
        {
            button.selected = true
           
            self.delegate!.difficultyChanged(button.tag)
            
            for btn in self.buttonsInSubViews()
            {
                if !btn.isEqual(button)
                {
                    let otherButton = btn
                    otherButton.selected = false
                }
            }
        }
    }
    
    func setSelectedButton(difficulty : Int)
    {
        for button in self.buttonsInSubViews()
        {
            if button.tag == difficulty
            {
                button.selected = true
            }
        }
    }
}
