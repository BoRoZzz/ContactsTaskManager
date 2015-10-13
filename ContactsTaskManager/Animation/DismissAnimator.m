//
//  DismissAnimator.m
//  TestArtRecognizer
//
//  Created by Borys Khliebnikov on 10/9/15.
//  Copyright © 2015 Borys Khliebnikov. All rights reserved.
//

#import "DismissAnimator.h"

@implementation DismissAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIView* inView = [transitionContext containerView];
    
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    CGPoint centerOffScreen = inView.center;
    centerOffScreen.y = (-1)*inView.frame.size.height;
    
    [UIView animateKeyframesWithDuration:0.5f delay:0.0f options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.5 animations:^{
            
            CGPoint center = fromViewController.view.center;
            center.y += 50;
            fromViewController.view.center = center;
        }];
        
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
            
            fromViewController.view.center = centerOffScreen;
            
        }];
        
        
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
        NSLog(@"TEST MSG: Animation completed");
    }];
    /*
    // Get the view controllers for the transition
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    // Add the view of the toViewController to the containerView
    [[transitionContext containerView] addSubview:toViewController.view];
    
    [UIView animateWithDuration:3.0f animations:^{
        fromViewController.view.alpha = 1.0f;
    }];
     */
}


@end
