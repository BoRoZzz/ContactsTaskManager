//
//  MasterTableViewController.m
//  ContactsTaskManager
//
//  Created by Borys Khliebnikov on 9/17/15.
//  Copyright © 2015 Borys Khliebnikov. All rights reserved.
//

@import Contacts;

#import "MasterTableViewController.h"
#import "DetailsTableViewController.h"
#import "TaskObject.h"
#import "TaskCell.h"
#import "Model.h"

@interface MasterTableViewController () <UpdatingDelegate, TaskCellDelegate>

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSMutableArray *tasks;
@property (strong, nonatomic) Model *model;

@end

@implementation MasterTableViewController

#pragma mark - Lazy instantiation

- (NSMutableArray *)tasks {
    if (!_tasks) {
        _tasks = [[NSMutableArray alloc] init];
    }
    return _tasks;
}

- (Model *)model {
    if (!_model) {
        _model = [[Model alloc] init];
    }
    return _model;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        _dateFormatter.timeStyle = NSDateFormatterShortStyle;
    }
    return _dateFormatter;
}

#pragma mark - ViewController life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Loading saved data
    self.tasks = [self.model loadData];
    
    // Gesture recognizers
    // Setting task to done
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(makeTaskDone:)];
    [self.tableView addGestureRecognizer:swipeRight];
    // Reordering cells
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.tableView addGestureRecognizer:longPress];
    [longPress setCancelsTouchesInView:NO];
    [swipeRight setCancelsTouchesInView:NO];
}

#pragma mark - UpdatingDelegate methods

- (void)updateTask:(TaskObject *)task forRow:(long)row {
    @synchronized(self.tasks) {
        [self.tasks replaceObjectAtIndex:row withObject:task];
        NSLog(@"Tasks after update are: %@", self.tasks);
    }
    @synchronized(self.tasks) {
        [self.model saveData:self.tasks];
    }
    @synchronized(self.tasks) {
        [self.tableView reloadData];
    }
    
    // Scheduling local notification for every task updated
    NSDate *currentDate = [NSDate dateWithTimeIntervalSinceNow:300];
    if (task.savedDate == [task.savedDate laterDate:currentDate]) {
        NSLog(@"TEST MSG: Date is differ > adding notification");
        // Removing existing noticication
        UIApplication *app = [UIApplication sharedApplication];
        NSArray *eventArray = [app scheduledLocalNotifications];
        for (UILocalNotification *event in eventArray) {
            //NSLog(@"TEST MSG: There are: Local notification uid %@", [event.userInfo objectForKey:@"uid"]);
            if ([[event.userInfo objectForKey:@"uid"] isEqualToString:task.uid]) {
                NSLog(@"TEST MSG: Removing local notification");
                [[UIApplication sharedApplication]cancelLocalNotification:event];
            }
        }
        [self scheduleLocalNotificationForTask:task];
    }

}

- (void)addNewTask:(TaskObject *)task {
    NSLog(@"Delegate of add task works");
    @synchronized(self.tasks) {
        task.isDone = @NO;
        [self.tasks insertObject:task atIndex:0];
        NSLog(@"New task added, tasks are: %@", self.tasks);
    }
    @synchronized(self.tasks) {
        [self.model saveData:self.tasks];
    }
    @synchronized(self.tasks) {
        [self.tableView reloadData];
    }
    
    // Scheduling local notification for every task added
    NSDate *currentDate = [NSDate dateWithTimeIntervalSinceNow:300];
    if (task.savedDate == [task.savedDate laterDate:currentDate]) {
        NSLog(@"TEST MSG: Date is differ > adding notification");
        NSLog(@"Saved date is %@ and today is %@", task.savedDate, currentDate);
        [self scheduleLocalNotificationForTask:task];
    }
}

#pragma mark - TaskCell delegate

- (void)buttonToCallWasTappedOnCell:(TaskCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSLog(@"IndexPath for buttonInCellToCall is %@", indexPath);
    [self chooseNumberForIndex:indexPath];
}

#pragma mark - Helper methods

// Local notifications method
- (void)scheduleLocalNotificationForTask:(TaskObject *)task {
    // Register the notification
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    // Creating local notification
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.timeZone    = [NSTimeZone defaultTimeZone];
    notification.alertAction = nil;
    notification.alertTitle  = task.taskText;
    notification.alertBody   = [NSString stringWithFormat:@"%@\n%@", task.taskText, task.detailedTaskText];
    notification.fireDate    = [task.savedDate dateByAddingTimeInterval:60];
    NSLog(@"Fire date is %@", notification.fireDate);
    notification.applicationIconBadgeNumber = 1;
    notification.soundName   = UILocalNotificationDefaultSoundName;
    notification.repeatInterval = 0;
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:task.uid forKey:@"uid"];
    notification.userInfo = infoDict;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    // For testing
    //[[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    NSLog(@"TEST MSG: Local notification has been scheduled");
}



// Shapshot for custom reordering
- (UIView *)customSnapshotFromView:(UIView *)inputView {
    UIView *snapshot = [inputView snapshotViewAfterScreenUpdates:YES];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    return snapshot;
}

// Calling methods
-(void)chooseNumberForIndex:(NSIndexPath *)index {
    TaskObject *temp = [self.tasks objectAtIndex:index.row];
    if ([temp.phoneNumbers count]) {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Please choose the number" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        for (CNLabeledValue *number in temp.phoneNumbers) {
            // Parsing values
            CNPhoneNumber *cell = number.value;
            NSString *label = [number.label stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_$!<>"]];
            NSString *fullNumber = [NSString stringWithFormat:@"%@: %@", label, cell.stringValue];
            // Lets action do its job
            UIAlertAction *option = [UIAlertAction actionWithTitle:fullNumber style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self callToNumber:number.value];
            }];
            
            [actionSheet addAction:option];
        }
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [actionSheet addAction:cancel];
        [self presentViewController:actionSheet animated:YES completion:nil];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Check your name" message:@"You don't have any number assigned" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)callToNumber:(CNPhoneNumber *)number {
    NSString *phoneStr = [NSString stringWithFormat:@"tel:%@",number.stringValue];
    //NSLog(@"TEST MSG: Phone string is %@", phoneStr);
    NSURL *url = [NSURL URLWithString:phoneStr];
    NSLog(@"TEST MSG: URL is %@", url);
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - Gesture recognizer methods

// Reordering cells
- (IBAction)longPressGestureRecognized:(id)sender {
    
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    
    CGPoint location = [longPress locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    // Snapshot of the row
    static UIView       *snapshot = nil;
    // Initial index path, where gesture begins
    static NSIndexPath  *sourceIndexPath = nil;
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath) {
                sourceIndexPath = indexPath;
                
                TaskCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                
                // Take a snapshot of the selected row using helper method.
                snapshot = [self customSnapshotFromView:cell];
                
                // Add the snapshot as subview
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [self.tableView addSubview:snapshot];
                [UIView animateWithDuration:0.25 animations:^{
                    
                    // Offset for gesture location
                    center.y = location.y;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapshot.alpha = 0.98;
                    
                    // Fade out
                    cell.alpha = 0.0;
                    
                } completion:^(BOOL finished) {
                    
                    cell.hidden = YES;
                    
                }];
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            [longPress setCancelsTouchesInView:YES];
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            
            // Is destination valid and is it different
            if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
                
                // Update data source
                [self.tasks exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                
                // Move the rows
                [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                // Saving new data
                [self.model saveData:self.tasks];
                
                // Update source so it is in sync with UI changes
                sourceIndexPath = indexPath;
            }
            break;
        }
        default: {
            // Clean up
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
            cell.hidden = NO;
            cell.alpha = 0.0;
            [UIView animateWithDuration:0.25 animations:^{
                
                snapshot.center = cell.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0.0;
                
                // Undo fade out
                cell.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                
                sourceIndexPath = nil;
                [snapshot removeFromSuperview];
                snapshot = nil;
                
            }];
            break;
        }
    }
}

// Setting task to done
-(IBAction)makeTaskDone:(id)sender {
    UISwipeGestureRecognizer *swipeDone = (UISwipeGestureRecognizer *)sender;
    CGPoint location = [swipeDone locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    TaskCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    TaskObject *task;
    if (indexPath && ([self.tasks count] != 0)) {
        task = [self.tasks objectAtIndex:indexPath.row];
        NSLog(@"TEST MSG: makeTaskDone swipe");
        if ([task.isDone isEqual:@NO]) {
            NSLog(@"TEST: isDone = NO");
            task.isDone = @YES;
            [swipeDone setCancelsTouchesInView:YES];
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:([self.tasks count] - 1) inSection:0];
            [self.tasks removeObjectAtIndex:indexPath.row];
            [self.tasks addObject:task];
            //NSLog(@"TEST MSG: (After done) Tasks position in array: %@", self.tasks);
            // Updating cell parameters
            cell.backgroundColor = [UIColor grayColor];
            cell.taskLabel.backgroundColor = [UIColor clearColor];
            cell.taskLabel.textColor = [UIColor whiteColor];
            cell.dateLabel.textColor = [UIColor whiteColor];
            cell.dateLabel.backgroundColor = [UIColor clearColor];
            [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            [self.model saveData:self.tasks];
        } else {
            NSLog(@"TEST MSG: isDone = YES");
            task.isDone = @NO;
            [swipeDone setCancelsTouchesInView:YES];
            [self.tasks removeObjectAtIndex:indexPath.row];
            [self.tasks insertObject:task atIndex:0];
            //NSLog(@"TEST MSG: (After undone) Tasks position in array: %@", self.tasks);
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            // Updating cell parameters
            cell.backgroundColor = [UIColor whiteColor];
            cell.taskLabel.backgroundColor = [UIColor clearColor];
            cell.taskLabel.textColor = [UIColor blackColor];
            cell.dateLabel.textColor = [UIColor blackColor];
            cell.dateLabel.backgroundColor = [UIColor clearColor];
            [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            [self.model saveData:self.tasks];
        }
        
    }
}


#pragma mark - TableView delegate and data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if([self.tasks count]>0) {
        return [self.tasks count];
    } else {
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TaskCell *cell = [tableView dequeueReusableCellWithIdentifier:@"taskCell" forIndexPath:indexPath];
    
    // Configure the cell...
    if([self.tasks count]>0) {
        // Obtaining task object
        TaskObject *task = [self.tasks objectAtIndex:indexPath.row];
        cell.taskLabel.text = task.taskText;
        [cell.buttonInCellToCall setEnabled:YES];
        cell.dateLabel.text = [self.dateFormatter stringFromDate:task.savedDate];
        // Checking for contact image
        if (task.contactImage) {
            cell.contactImage.image = [UIImage imageWithData:task.contactImage];
        } else {
            cell.contactImage.image = [UIImage imageNamed:@"default"];
        }
        // Checking for DONE status
        if ([task.isDone isEqual:@YES]) {
            cell.backgroundColor           = [UIColor grayColor];
            cell.taskLabel.backgroundColor = [UIColor clearColor];
            cell.taskLabel.textColor       = [UIColor whiteColor];
            cell.dateLabel.textColor       = [UIColor whiteColor];
            cell.dateLabel.backgroundColor = [UIColor clearColor];
        } else {
            cell.backgroundColor           = [UIColor whiteColor];
            cell.taskLabel.backgroundColor = [UIColor clearColor];
            cell.taskLabel.textColor       = [UIColor blackColor];
            cell.dateLabel.textColor       = [UIColor blackColor];
            cell.dateLabel.backgroundColor = [UIColor clearColor];
        }
        // Checking for late tasks
        /*
        if ([task.isDone isEqual:@NO] && task.savedDate == [task.savedDate earlierDate:[NSDate date]]) {
            cell.backgroundColor = [UIColor colorWithRed:128.0f green:0.0f blue:0.0f alpha:0.2f];
        }
         */
    } else {
        cell.taskLabel.text = @"Place for your task";
        cell.contactImage.image = [UIImage imageNamed:@"default"];
        cell.dateLabel.text = @"Place for date";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.buttonInCellToCall setEnabled:NO];
    }
    // General parameters for cell
    [cell.buttonInCellToCall setBackgroundImage:[UIImage imageNamed:@"default"] forState:UIControlStateNormal];
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.tasks count]) {
        [self performSegueWithIdentifier:@"updateTask" sender:self];
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if ([self.tasks count]) {
        return YES;
    } else {
        return NO;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Counting to prevent crashing while deleting the first row
        if ([self.tasks count] >= 1) {
            [tableView beginUpdates];
            // Delete the row from the data source
            @synchronized(self.tasks) {
                [self.tasks removeObjectAtIndex:indexPath.row];
            }
            // Saving changes
            @synchronized(self.tasks) {
                [self.model saveData:self.tasks];
            }
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            if ([self.tasks count] == 0) {
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
            [tableView endUpdates];
        }
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    if ([self.tasks count] > 1) {
        return YES;
    }
    return NO;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"updateTask"]) {
        if ([sender isKindOfClass:[MasterTableViewController class]]) {
            DetailsTableViewController *vc = (DetailsTableViewController *)segue.destinationViewController;
            NSIndexPath *path = [self.tableView indexPathForSelectedRow];
            //NSLog(@"TEST MSG: IndexPath to pass is %@", path);
            vc.passedTask = [self.tasks objectAtIndex:path.row];
            vc.indexPathForSave = path.row;
            vc.delegate = self;
        }
    } else if ([segue.identifier isEqualToString:@"addTask"]) {
        if ([sender isKindOfClass:[UIBarButtonItem class]]) {
            DetailsTableViewController *vc = (DetailsTableViewController *)segue.destinationViewController;
            vc.delegate = self;
        }
    }
}

#pragma mark - Application life cycle

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
