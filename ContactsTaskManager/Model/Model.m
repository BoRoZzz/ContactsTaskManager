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

- (void)saveData:(NSDictionary *)data {
    //NSLog(@"TEST MSG: saveData works, data is %@",data);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *docfilePath = [basePath stringByAppendingPathComponent:@"Model.plist"];
    //NSLog(@"TEST MSG: saving to %@", docfilePath);
    [data writeToFile:docfilePath atomically:YES];
}

- (NSDictionary *)loadData {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *docfilePath = [basePath stringByAppendingPathComponent:@"Model.plist"];
    NSDictionary *plistdict = [NSDictionary dictionaryWithContentsOfFile:docfilePath];
    //NSLog(@"TEST MSG: loadData is %@", plistdict);
    return plistdict;
}

@end
