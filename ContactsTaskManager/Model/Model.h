//
//  Model.h
//  ContactsTaskManager
//
//  Created by Borys Khliebnikov on 9/18/15.
//  Copyright © 2015 Borys Khliebnikov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Model : NSObject

- (void)saveData:(NSMutableArray *)data;
- (NSMutableArray *)loadData;

@end
