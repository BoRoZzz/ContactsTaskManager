//
//  TaskObject.m
//  ContactsTaskManager
//
//  Created by Borys Khliebnikov on 9/18/15.
//  Copyright © 2015 Borys Khliebnikov. All rights reserved.
//

#import "TaskObject.h"
#import "Defines.h"

@implementation TaskObject

-(instancetype)init {
    self = [self initWithData:nil];
    return self;
}

// Designated initializer
-(instancetype)initWithData:(NSDictionary *)data {
    self = [super init];
    
    self.taskText         = data[USER_TASK];
    self.savedDate        = data[USER_DATE];
    self.detailedTaskText = data[USER_DESCRIPTION];
    self.isDone           = data[USER_BOOL];
    self.uid              = data[USER_UID];
    self.contactImage     = data[CONTACT_IMAGE];
    self.contactFullName  = data[CONTACT_FULLNAME];
    self.phoneNumbers     = data[CONTACT_NUMBER];
    
    return self;
}

@end
