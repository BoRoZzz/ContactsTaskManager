//
//  taskCell.h
//  ContactsTaskManager
//
//  Created by Borys Khliebnikov on 9/18/15.
//  Copyright © 2015 Borys Khliebnikov. All rights reserved.
//

#import <UIKit/UIKit.h>

// Protocol for sharing IndexPath
@class TaskCell;
@protocol TaskCellDelegate
- (void)buttonToCallWasTappedOnCell:(TaskCell *)cell;
@end

@interface TaskCell : UITableViewCell

// Delegate
@property (weak, nonatomic) id<TaskCellDelegate> delegate;

// Outlets
@property (weak, nonatomic) IBOutlet UIButton *buttonInCellToCall;
@property (weak, nonatomic) IBOutlet UILabel *taskLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *contactImage;

@end
