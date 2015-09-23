//
//  TaskObject.h
//  ContactsTaskManager
//
//  Created by Borys Khliebnikov on 9/18/15.
//  Copyright © 2015 Borys Khliebnikov. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TaskObject : NSObject

// Task details
@property (strong, nonatomic) NSString *taskText;
@property (strong, nonatomic) NSString *savedDate;
@property (strong, nonatomic) NSString *detailedTaskText;
@property (strong, nonatomic) NSNumber *isDone;

// Contact details
@property (strong, nonatomic) NSData   *contactImage;
@property (strong, nonatomic) NSString *contactFullName;
@property (strong, nonatomic) NSArray  *phoneNumbers;

@end
