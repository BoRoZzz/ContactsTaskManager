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


- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.taskText         forKey:USER_TASK];
    [aCoder encodeObject:self.savedDate        forKey:USER_DATE];
    [aCoder encodeObject:self.detailedTaskText forKey:USER_DESCRIPTION];
    [aCoder encodeObject:self.isDone           forKey:USER_BOOL];
    [aCoder encodeObject:self.contactImage     forKey:CONTACT_IMAGE];
    [aCoder encodeObject:self.contactFullName  forKey:CONTACT_FULLNAME];
    [aCoder encodeObject:self.phoneNumbers     forKey:CONTACT_NUMBER];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super init]){
        self.taskText         = [aDecoder decodeObjectForKey:USER_TASK];
        self.savedDate        = [aDecoder decodeObjectForKey:USER_DATE];
        self.detailedTaskText = [aDecoder decodeObjectForKey:USER_DESCRIPTION];
        self.isDone           = [aDecoder decodeObjectForKey:USER_BOOL];
        self.contactImage     = [aDecoder decodeObjectForKey:CONTACT_IMAGE];
        self.contactFullName  = [aDecoder decodeObjectForKey:CONTACT_FULLNAME];
        self.phoneNumbers     = [aDecoder decodeObjectForKey:CONTACT_NUMBER];
    }
    return self;
}

@end
