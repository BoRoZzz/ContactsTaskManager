//
//  CustomAnimation.h
//  ContactsTaskManager
//
//  Created by Borys Khliebnikov on 9/27/15.
//  Copyright © 2015 Borys Khliebnikov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CustomAnimation : NSObject <UIViewControllerAnimatedTransitioning>

@property (strong, nonatomic) UIVisualEffectView *visualView;

@end
