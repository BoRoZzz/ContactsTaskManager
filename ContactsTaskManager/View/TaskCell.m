//
//  taskCell.m
//  ContactsTaskManager
//
//  Created by Borys Khliebnikov on 9/18/15.
//  Copyright © 2015 Borys Khliebnikov. All rights reserved.
//

#import "TaskCell.h"

@interface TaskCell ()

@end

@implementation TaskCell

- (IBAction)buttonTapped:(id)sender {
    [self.delegate buttonToCallWasTappedOnCell:self];
}


@end
