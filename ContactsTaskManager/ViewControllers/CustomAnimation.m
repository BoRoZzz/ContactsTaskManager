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
    
    // Creating blur effect
    self.visualView.frame = fromViewController.view.frame;
    [fromViewController.view addSubview:self.visualView];
    // Prepare the view of the toViewController
    CGRect endFrame = CGRectMake(40, 40, toViewController.view.frame.size.width - 80, toViewController.view.frame.size.height - 80);
    toViewController.view.frame = CGRectOffset(endFrame, 0.6f*fromViewController.view.frame.size.width, 0);
    
    
    // Add the view of the toViewController to the containerView
    [[transitionContext containerView] addSubview:toViewController.view];
    
    // Create animator
    __block UIDynamicAnimator  *animator = [[UIDynamicAnimator alloc] initWithReferenceView:[transitionContext containerView]];
    
    // Add behaviors
    UISnapBehavior* snapBehavior = [[UISnapBehavior alloc] initWithItem:toViewController.view snapToPoint:fromViewController.view.center];
    [animator addBehavior:snapBehavior];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([self transitionDuration:transitionContext] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        animator = nil;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    });
}

@end
