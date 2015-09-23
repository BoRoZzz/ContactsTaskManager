//
//  Model.m
//  ContactsTaskManager
//
//  Created by Borys Khliebnikov on 9/18/15.
//  Copyright © 2015 Borys Khliebnikov. All rights reserved.
//

#import "Model.h"
#import "MasterTableViewController.h"
#import "TaskObject.h"

@interface Model ()


@end

@implementation Model

#pragma mark - Instantination

- (instancetype)init {
    self = [super init];
    if (self) {
    
    }
    return self;
}


#pragma mark - SerializationDelegate methods

- (void)saveData:(NSMutableArray *)data {
    NSLog(@"TEST MSG: saveData works, data is %@",data);
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:@"appData"];
    [NSKeyedArchiver archiveRootObject:data toFile:filePath];
}

- (NSMutableArray *)loadData {
    NSLog(@"TEST MSG: loadData works");
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:@"appData"];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSMutableArray *savedData = [[NSKeyedUnarchiver unarchiveObjectWithData:data]mutableCopy];
        NSLog(@"TEST MSG: Data loaded succesfully: %@", savedData);
        return savedData;
    } else {
        NSLog(@"TEST MSG: There is no saved data.");
        return 0;
    }
}

@end
