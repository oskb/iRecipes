//
//  EditNameView.swift
//  iRecipes
//
//  Created by Oskar Bævre on 18/10/14.
//  Copyright (c) 2014 123. All rights reserved.
//

import UIKit

protocol EditNameViewDelegate
{
    func nameFieldNotEmpty()
    func nameFieldIsEmpty()
}

class EditNameView: BaseEditView, UITextFieldDelegate
{
    private let nameTextField = UITextField()
    private let nameFont = UIFont(name: "AmericanTypeWriter", size: 30.0)
    private var delegate : EditNameViewDelegate?
    
    init(frame: CGRect, delegate : EditNameViewDelegate?)
    {
        super.init(frame: frame)
        self.delegate = delegate
        self.addNameLabel("Name:")
        self.addTextField()
    }
    
    private func addTextField()
    {
        self.nameTextField.frame = CGRectMake(0.0, 0.0, self.frame.size.width - 20.0, 80.0)
        self.nameTextField.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2 + super.nameLabel.frame.size.height/2)
        self.nameTextField.font = self.nameFont
        self.nameTextField.textColor = self.nameTextField.tintColor
        self.nameTextField.adjustsFontSizeToFitWidth = true
        self.nameTextField.textAlignment = NSTextAlignment.Center
        self.nameTextField.userInteractionEnabled = true
        self.nameTextField.placeholder = "Type recipe name here..."
        self.nameTextField.returnKeyType = UIReturnKeyType.Done
        self.nameTextField.delegate = self
        self.addSubview(self.nameTextField)
        
        let hideKeyboardTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "textFieldShouldReturn:")
        self.addGestureRecognizer(hideKeyboardTapGestureRecognizer)
    }
    
    func setName(string :String)
    {
        self.nameTextField.text = string
    }
    
    func name() -> String
    {
        return self.nameTextField.text
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        if self.nameTextField.text.isEmpty
        {
            self.delegate!.nameFieldIsEmpty()
        }
        else
        {
            self.delegate!.nameFieldNotEmpty()
        }
        
        self.nameTextField.resignFirstResponder()
        return true
    }
}
