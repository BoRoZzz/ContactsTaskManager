//
//  CustomAnimation.m
//  ContactsTaskManager
//
//  Created by Borys Khliebnikov on 9/27/15.
//  Copyright © 2015 Borys Khliebnikov. All rights reserved.
//

#import "CustomAnimation.h"

@implementation CustomAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1.0f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    // Get the view controllers for the transition
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect endFrame   = CGRectMake(40, 40, toViewController.view.frame.size.width - 80, toViewController.view.frame.size.height - 80);
    
    toViewController.view.frame = endFrame;
    
    // Creating blur effect
    self.visualView.frame = fromViewController.view.frame;
    [fromViewController.view addSubview:self.visualView];
    
    // Add the view of the toViewController to the containerView
    [[transitionContext containerView] addSubview:toViewController.view];
    
    [toViewController.view setAlpha:0];
    [UIView beginAnimations:NULL context:nil];
    [UIView setAnimationDuration:0.5];
    [toViewController.view setAlpha:1.0];
    [UIView commitAnimations];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([self transitionDuration:transitionContext] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    });

}

@end
