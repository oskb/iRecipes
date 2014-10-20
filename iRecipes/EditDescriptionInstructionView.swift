//
//  EditDescriptionInstructionView.swift
//  iRecipes
//
//  Created by Oskar Bævre on 18/10/14.
//  Copyright (c) 2014 123. All rights reserved.
//

import UIKit

class EditDescriptionInstructionView : BaseEditView
{
    let textView = UITextView()
    
    init(frame: CGRect, name : String, text : String?)
    {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
        
        super.addNameLabel(name)
        
        self.textView.frame = CGRectMake(10.0, 80.0, self.frame.size.width - 20.0, self.frame.size.height - 80.0)
        self.textView.textAlignment = NSTextAlignment.Center
        self.textView.textColor = self.textView.tintColor
        self.textView.font = UIFont(name: "AmericanTypeWriter", size: 18.0)
        self.textView.editable = true
        self.addSubview(self.textView)
        
        if let textString = text
        {
            self.textView.text = textString
        }
        
        self.addDoneButton()
    }
    
    private func addDoneButton()
    {
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self.textView, action: "resignFirstResponder")
        let toolBar = UIToolbar(frame: CGRectMake(0.0, 0.0, self.textView.frame.size.width, 44.0))
        toolBar.items = [UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil), doneButton]
        
        self.textView.inputAccessoryView = toolBar
    }
    
    func textViewText() -> String?
    {
        return self.textView.text
    }
}