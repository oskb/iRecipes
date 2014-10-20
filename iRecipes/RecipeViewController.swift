//
//  RecipeViewController.swift
//  iRecipes
//
//  Created by Oskar Bævre on 13/10/14.
//  Copyright (c) 2014 123. All rights reserved.
//

import UIKit

class RecipeViewController : UIViewController, UINavigationControllerDelegate
{
    private var recipe : Recipe?
    private var interactivePopTransition = UIPercentDrivenInteractiveTransition()
    private var isInteractive = false
    private var originalFavoriteValue = false
    private var editRecipeViewController : EditRecipeViewController?
    var favoriteStarView : FavoriteStarView?
    
    let imageView = ImageView()
    let nameTextField = UITextField()
    let difficultyLabel = UILabel()
    let descriptionInstructionTextView = UITextView()
    
    init(recipe : Recipe)
    {
        super.init(nibName: nil, bundle: nil)
        self.recipe = recipe
        
        if let favorite = recipe.favorite?.boolValue
        {
            self.originalFavoriteValue = favorite
        }
    }

    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge.None
        self.view.backgroundColor = UIColor.whiteColor()

        self.addNavigationBarEditButton()
        self.addPopGestureRecognizer()
        self.addRecipeImageView()
        self.addFavoriteStarView()
        self.addNameTextField()
        self.addDifficultyLabel()
        self.addDescriptionInstructionTextView()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.delegate = self
        
        self.setRecipeValuesOnComponents()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        if let navigationControllerDelegate = self.navigationController?.delegate
        {
            if navigationControllerDelegate.isEqual(self)
            {
                self.navigationController?.delegate = nil;
            }
        }
        
        self.updateRecipeIfFavoriteStatusChanged()
    }
    
    //MARK: Setup
    
    private func addNavigationBarEditButton()
    {
        let editButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: "editRecipe")
        self.navigationItem.rightBarButtonItem = editButton
    }
    
    private func addPopGestureRecognizer()
    {
        let popGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: "handlePopGesture:")
        popGestureRecognizer.edges = UIRectEdge.Left
        self.view.addGestureRecognizer(popGestureRecognizer)
    }
    
    private func addRecipeImageView()
    {
        self.imageView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, 200.0)
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.view.addSubview(self.imageView)
    }
    
    private func addFavoriteStarView()
    {
        self.favoriteStarView = FavoriteStarView(frame: CGRectMake(0.0, 0.0, 45.0, 45.0), starColor: self.starColor())
        self.favoriteStarView!.center = CGPointMake(30.0, 200.0)
        self.view.addSubview(self.favoriteStarView!)
        
        let toggleFavoriteTapRecognizer = UITapGestureRecognizer(target: self, action: "toggleFavorite")
        self.favoriteStarView?.addGestureRecognizer(toggleFavoriteTapRecognizer)
    }
    
    private func addNameTextField()
    {
        self.nameTextField.frame = CGRectMake(10.0, 220.0, self.view.frame.size.width - 20.0, 30.0)
        self.nameTextField.font = UIFont(name: "AmericanTypeWriter", size: 24.0)
        self.nameTextField.adjustsFontSizeToFitWidth = true
        self.nameTextField.textAlignment = NSTextAlignment.Center
        self.nameTextField.text = self.recipe?.name
        self.nameTextField.userInteractionEnabled = false
        self.view.addSubview(self.nameTextField)
    }
    
    private func addDifficultyLabel()
    {
        self.difficultyLabel.frame = CGRectMake(self.view.frame.size.width - 100.0, 200.0, 100.0, 20.0)
        self.difficultyLabel.font = UIFont(name: "AmericanTypeWriter", size: 14.0)
        self.difficultyLabel.adjustsFontSizeToFitWidth = true
        self.difficultyLabel.textAlignment = NSTextAlignment.Center
        self.view.addSubview(self.difficultyLabel)
    }
    
    private func addDescriptionInstructionTextView()
    {
        self.descriptionInstructionTextView.frame = CGRectMake(10.0, 260.0, self.view.frame.size.width - 20.0, self.view.frame.size.height - 300.0)
        self.descriptionInstructionTextView.textAlignment = NSTextAlignment.Left
        self.descriptionInstructionTextView.editable = false
        self.view.addSubview(self.descriptionInstructionTextView)
    }
    
    private func setRecipeValuesOnComponents()
    {
        self.imageView.loadImageAnimated(false, imageData: self.recipe?.photo)
        self.nameTextField.text = self.recipe?.name
        
        if let difficulty = self.recipe?.difficulty
        {
            self.difficultyLabel.text = "Difficulty: \(difficulty)"
        }
        
        self.descriptionInstructionTextView.attributedText = self.descriptionAndInstructionText()
    }
    
    private func descriptionAndInstructionText() -> NSAttributedString
    {
        let descriptionAndInstrucionText = NSMutableAttributedString()
        
        if let description = self.recipe?.descr
        {
            let descriptionHeaderString = self.attributedHeaderStringWithText("Description:\n")
            let descriptionBodyString = self.attributedBodyStringWithText(description)
            
            descriptionAndInstrucionText.insertAttributedString(descriptionHeaderString, atIndex: descriptionAndInstrucionText.length)
            
            descriptionAndInstrucionText.insertAttributedString(descriptionBodyString, atIndex: descriptionAndInstrucionText.length)
        }
        
        if let instructions = self.recipe?.instructions
        {
            let instructionHeaderString = self.attributedHeaderStringWithText("\n\nInstructions:\n")
            let instructionBodyString = self.attributedBodyStringWithText(instructions)
            
            descriptionAndInstrucionText.insertAttributedString(instructionHeaderString, atIndex: descriptionAndInstrucionText.length)
            descriptionAndInstrucionText.insertAttributedString(instructionBodyString, atIndex: descriptionAndInstrucionText.length)
        }
        
        return descriptionAndInstrucionText
    }
    
    private func attributedHeaderStringWithText(string : String) -> NSAttributedString
    {
        return NSAttributedString(string: "\(string)", attributes: [NSForegroundColorAttributeName : self.descriptionInstructionTextView.tintColor,
            NSFontAttributeName : UIFont(name: "AmericanTypeWriter", size: 18.0)])
    }
    
    private func attributedBodyStringWithText(string : String) ->NSAttributedString
    {
        return NSAttributedString(string: string, attributes: [NSForegroundColorAttributeName : UIColor.blackColor(),
            NSFontAttributeName : UIFont(name: "AmericanTypeWriter", size: 16.0)])
    }
    
    //MARK: Edit
    
    func editRecipe()
    {
        self.editRecipeViewController = EditRecipeViewController(recipe: recipe!)
        self.editRecipeViewController?.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        
        if self.imageView.isImageLoadingIndicatorAnimating()
        {
            self.editRecipeViewController?.isImageLoading = true
        }
        
        let navigationController =
        UINavigationController(rootViewController: self.editRecipeViewController!)
        
        self.navigationController?.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    //MARK: Handle favorite
    
    private func starColor() -> UIColor
    {
        var starColor = UIColor(red: 0.85, green: 0.85, blue: 0.9, alpha: 1.0)
        
        if let favorite = self.recipe?.favorite
        {
            if favorite.boolValue
            {
                starColor = UIColor.orangeColor()
            }
        }
        
        return starColor
    }
    
    func toggleFavorite()
    {
        if let favorite = self.recipe?.favorite
        {
            if favorite.boolValue
            {
                self.recipe?.favorite = false
            }
            else
            {
                self.recipe?.favorite = true
            }
        }
        else
        {
            self.recipe?.favorite = true
        }
        
        self.favoriteStarView?.rotateStarAndSetNewColor(self.starColor())
    }
    
    private func updateRecipeIfFavoriteStatusChanged()
    {
        if let recipeFavorite = self.recipe?.favorite
        {
            if self.originalFavoriteValue != recipeFavorite
            {
                DataManager.sharedDataManager.updateRecipe(self.recipe!)
            }
        }
    }
    
    //MARK: Image handling
    
    func startImageLoadingIndicator()
    {
        self.imageView.startImageLoadingIndicator()
    }
    
    func loadRecipeImageForRecipe(recipe : Recipe)
    {
        if recipe.id == self.recipe?.id
        {
            self.imageView.stopImageLoadingIndicator()
            self.imageView.loadImageAnimated(true, imageData: self.recipe?.photo)
            self.editRecipeViewController?.loadRecipeImageForRecipe(recipe)
        }
    }
    
    //MARK: UINavigationControllerDelegate
    
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
    {
        if  self.isInteractive
        {
            return self.interactivePopTransition
        }
        
        return nil
    }
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        if fromVC.isKindOfClass(RecipeViewController) && toVC.isKindOfClass(RecipesViewController)
        {
            return RecipeDismissalAnimator()
        }
        else
        {
            return nil
        }
    }
    
    //MARK: GestureRecognizerHandler
    
    func handlePopGesture(recognizer : UIScreenEdgePanGestureRecognizer)
    {
        var progress : CGFloat = recognizer.translationInView(self.view).x / CGRectGetWidth(self.view.bounds) * 0.6
        progress = min(1.0, max(0.0, progress))
        
        if recognizer.state == UIGestureRecognizerState.Began
        {
            self.isInteractive = true
            self.interactivePopTransition = UIPercentDrivenInteractiveTransition()
            self.navigationController?.popViewControllerAnimated(true)
        }
        else if recognizer.state == UIGestureRecognizerState.Changed
        {
            self.interactivePopTransition.updateInteractiveTransition(progress)
        }
        else if recognizer.state == UIGestureRecognizerState.Ended || recognizer.state == UIGestureRecognizerState.Cancelled
        {
            if progress > 0.4
            {
                self.interactivePopTransition.finishInteractiveTransition()
            }
            else
            {
                self.interactivePopTransition.cancelInteractiveTransition()
            }
            
            self.isInteractive = false
        }
    }
}

