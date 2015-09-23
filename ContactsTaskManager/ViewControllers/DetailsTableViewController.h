//
//  DetailsTableViewController.h
//  ContactsTaskManager
//
//  Created by Borys Khliebnikov on 9/18/15.
//  Copyright © 2015 Borys Khliebnikov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskObject.h"

// Protocol for passing an updated task to master
@class DetailsTableViewController;
@protocol UpdatingDelegate <NSObject>

- (void)updateTask:(TaskObject *)task forRow:(long)row;
- (void)addNewTask:(TaskObject *)task;

@end

@interface DetailsTableViewController : UITableViewController

// Deledate
@property (weak, nonatomic) id <UpdatingDelegate> delegate;

// Passed data
@property (strong, nonatomic) TaskObject *passedTask;
@property (nonatomic) long indexPathForSave;

@end
