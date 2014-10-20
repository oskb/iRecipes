//
//  RecipePresentationAnimator.swift
//  iRecipes
//
//  Created by Oskar Bævre on 14/10/14.
//  Copyright (c) 2014 123. All rights reserved.
//

class RecipePresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning
{
    var imageViewOriginalCenter : CGPoint!
    var toggleFavoriteViewOriginalCenter : CGPoint!
    var difficultyLabelOriginalCenter : CGPoint!
    var nameTextFieldOriginalCenter : CGPoint!
    var textViewOriginalCenter : CGPoint!
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning)
    {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)! as RecipesViewController
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)! as RecipeViewController
        let containerView = transitionContext.containerView()
        let animationDuration = self.transitionDuration(transitionContext)
        
        
        self.setInitialValuesOnToViewController(toViewController, transitionContext: transitionContext)
        containerView.addSubview(toViewController.view)
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            
            fromViewController.view.center = CGPointMake(-fromViewController.view.frame.size.width, fromViewController.view.center.y)
            
        }) { (Bool) -> Void in
            
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                toViewController.view.alpha = 1.0
            })
            
            self.animateInImage(toViewController)
            self.animateInFavoriteStar(toViewController)
            self.animateInDifficulty(toViewController)
            self.animateInName(toViewController)
            self.animateInDescriptionAndInstructionsThenFinishTransition(toViewController, containerView: containerView, transitionContext: transitionContext)
        }
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval
    {
        return 1.5
    }
    
    //MARK: Private helpers
    
    private func setInitialValuesOnToViewController(toViewController : RecipeViewController, transitionContext : UIViewControllerContextTransitioning)
    {
        toViewController.view.alpha = 0.0
        toViewController.view.frame = transitionContext.finalFrameForViewController(toViewController)
        
        self.imageViewOriginalCenter = toViewController.imageView.center
        toViewController.imageView.center = CGPointMake(1000.0, toViewController.imageView.center.y)
        
        self.toggleFavoriteViewOriginalCenter = toViewController.favoriteStarView!.center
        toViewController.favoriteStarView!.center = CGPointMake(toViewController.view.frame.size.width * 2, toViewController.favoriteStarView!.center.y)
        
        self.difficultyLabelOriginalCenter = toViewController.difficultyLabel.center
        toViewController.difficultyLabel.center = CGPointMake(1000.0, toViewController.difficultyLabel.center.y)
        
        self.nameTextFieldOriginalCenter = toViewController.nameTextField.center
        toViewController.nameTextField.center = CGPointMake(1000.0, toViewController.nameTextField.center.y)
        
        self.textViewOriginalCenter = toViewController.descriptionInstructionTextView.center
        toViewController.descriptionInstructionTextView.center = CGPointMake(1000.0, toViewController.descriptionInstructionTextView.center.y)
    }
    
    private func animateInImage(toViewController : RecipeViewController)
    {
        UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
            
            toViewController.imageView.center = self.imageViewOriginalCenter
            
            }, completion: { (Bool) -> Void in })
    }
    
    private func animateInFavoriteStar(toViewController : RecipeViewController)
    {
        UIView.animateWithDuration(1.0, delay: 0.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.3, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
            
            toViewController.favoriteStarView!.center = self.toggleFavoriteViewOriginalCenter
            
            }, completion: { (Bool) -> Void in })
    }
    
    private func animateInDifficulty(toViewController : RecipeViewController)
    {
        UIView.animateWithDuration(1.0, delay: 0.2, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
            
            toViewController.difficultyLabel.center = self.difficultyLabelOriginalCenter
            
            }, completion: { (Bool) -> Void in })
    }
    
    private func animateInName(toViewController : RecipeViewController)
    {
        UIView.animateWithDuration(1.0, delay: 0.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.4, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
            
            toViewController.nameTextField.center = self.nameTextFieldOriginalCenter
            
            }, completion: { (Bool) -> Void in })
    }
    
    private func animateInDescriptionAndInstructionsThenFinishTransition(toViewController : RecipeViewController, containerView : UIView, transitionContext : UIViewControllerContextTransitioning)
    {
        UIView.animateWithDuration(1.0, delay: 0.4, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.6, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
            
            toViewController.descriptionInstructionTextView.center = self.textViewOriginalCenter
            
            }, completion: { (Bool) -> Void in
                containerView.bringSubviewToFront(toViewController.view)
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        })
    }
}
