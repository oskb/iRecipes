//
//  RecipeDismissalAnimator.swift
//  iRecipes
//
//  Created by Oskar Bævre on 14/10/14.
//  Copyright (c) 2014 123. All rights reserved.
//

import UIKit

class RecipeDismissalAnimator: NSObject, UIViewControllerAnimatedTransitioning
{
    func animateTransition(transitionContext: UIViewControllerContextTransitioning)
    {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)! as RecipeViewController
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let containerView = transitionContext.containerView()
        let animationDuration = self.transitionDuration(transitionContext)
        
        toViewController.view.center = CGPointMake(-toViewController.view.frame.size.width, toViewController.view.center.y)
        containerView.addSubview(toViewController.view)
        
        UIView.animateKeyframesWithDuration(1.0, delay: 0.0, options: UIViewKeyframeAnimationOptions.AllowUserInteraction, animations: { () -> Void in
            
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.4, animations: { () -> Void in
                fromViewController.imageView.center = CGPointMake(fromViewController.view.frame.size.width * 2, fromViewController.imageView.center.y)
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.8, animations: { () -> Void in
                fromViewController.favoriteStarView!.center = CGPointMake(fromViewController.view.frame.size.width * 2, fromViewController.favoriteStarView!.center.y)
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.1, relativeDuration: 0.25, animations: { () -> Void in
                fromViewController.difficultyLabel.center = CGPointMake(fromViewController.view.frame.size.width * 2, fromViewController.difficultyLabel.center.y)
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.1, relativeDuration: 0.7, animations: { () -> Void in
                fromViewController.nameTextField.center = CGPointMake(fromViewController.view.frame.size.width * 2, fromViewController.nameTextField.center.y)
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.2, relativeDuration: 0.8, animations: { () -> Void in
                fromViewController.descriptionInstructionTextView.center = CGPointMake(fromViewController.view.frame.size.width * 2, fromViewController.descriptionInstructionTextView.center.y)
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.25, relativeDuration: 0.5, animations: { () -> Void in
                    toViewController.view.frame = CGRectMake(50.0, 0.0, toViewController.view.frame.size.width, toViewController.view.frame.size.height)
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.80, relativeDuration: 0.2, animations: { () -> Void in
                toViewController.view.frame = transitionContext.finalFrameForViewController(toViewController)
            })
            
        }) { (Bool) -> Void in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval
    {
        return 1.0
    }
}
