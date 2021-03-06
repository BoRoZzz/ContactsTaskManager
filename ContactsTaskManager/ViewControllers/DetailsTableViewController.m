//
//  DetailsTableViewController.m
//  ContactsTaskManager
//
//  Created by Borys Khliebnikov on 9/18/15.
//  Copyright © 2015 Borys Khliebnikov. All rights reserved.
//

@import Contacts;
@import ContactsUI;

#import "DetailsTableViewController.h"

@interface DetailsTableViewController () <UITextFieldDelegate, UITextViewDelegate, CNContactPickerDelegate>

// Outlets
@property (weak, nonatomic) IBOutlet UITextField  *taskTextField;
@property (weak, nonatomic) IBOutlet UILabel      *deadlineLabelTitle;
@property (weak, nonatomic) IBOutlet UILabel      *deadlineLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIImageView  *contactImage;
@property (weak, nonatomic) IBOutlet UIButton     *buttonToCall;
@property (weak, nonatomic) IBOutlet UIButton     *contactNameButton;
@property (weak, nonatomic) IBOutlet UITextView   *detailsTextView;
@property (weak, nonatomic) IBOutlet UIButton     *updateButton;

// Private properties
@property (strong, nonatomic) NSDateFormatter   *dateFormatter;
@property (strong, nonatomic) NSArray           *phoneNumbers;
@property (strong, nonatomic) UIImage           *tempContactImage;

// Properties for managing the UIDatePicker
@property (nonatomic) BOOL datePickerIsShowing;
@property (nonatomic) BOOL datePickerHasBeenPressed;
@property (strong, nonatomic) NSDate *selectedDeadline;

@end

@implementation DetailsTableViewController

#pragma mark - Lazy instantiation

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
    
    // Obserser for hiding datePicker cell when the keyboard appers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    
    // Default settings for UI
    [self.buttonToCall setBackgroundImage:[UIImage imageNamed:@"icon_phone_detail"] forState:UIControlStateNormal];
    [self.updateButton setBackgroundImage:[UIImage imageNamed:@"icon_done"] forState:UIControlStateNormal];
    self.deadlineLabelTitle.text = @"Deadline: ";
    self.taskTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.navigationItem.hidesBackButton = YES;
    self.taskTextField.backgroundColor = [UIColor clearColor];
    
    // Setting view
    // Modal view styling
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowOffset = CGSizeMake(0.0, 8.0);
    self.view.layer.shadowOpacity = 0.5;
    self.view.layer.shadowRadius = 10.0;
    self.view.layer.cornerRadius = 3.0;
    self.tableView.layer.cornerRadius = 3.0;
    self.tableView.layer.masksToBounds = YES;
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableview_bg"]];
    [tempImageView setFrame:self.tableView.frame];
    self.tableView.backgroundView = tempImageView;
    
    // Setting delegates
    self.taskTextField.delegate = self;
    self.detailsTextView.delegate = self;
    
    // Syncing UI properties with a task object
    if (self.passedTask) {
        self.taskTextField.text = self.passedTask.taskText;
        self.deadlineLabel.text = [self.dateFormatter stringFromDate:self.passedTask.savedDate];
        if (![self.passedTask.contactImage isEqualToData: UIImagePNGRepresentation([UIImage imageNamed:@"icon_face_master"])]) {
            self.contactImage.image = [UIImage imageWithData:self.passedTask.contactImage];
        } else {
            self.contactImage.image = [UIImage imageNamed:@"icon_face_detail"];
        }
        if (self.passedTask.detailedTaskText) {
            self.detailsTextView.text = self.passedTask.detailedTaskText;
        } //else {
          //  self.detailsTextView.text = @"This is the place for details";
          //  self.detailsTextView.textColor = [UIColor lightGrayColor];
        //}
        [self.contactNameButton setTitle:self.passedTask.contactFullName forState:UIControlStateNormal];
        self.phoneNumbers = self.passedTask.phoneNumbers;
    } else {
        self.datePickerHasBeenPressed = 0;
        [self.contactNameButton setTitle:@"Assign a contact" forState:UIControlStateNormal];
        self.taskTextField.placeholder = @"Name your task here";
        self.deadlineLabel.text = [self.dateFormatter stringFromDate:[NSDate date]];
        self.contactImage.image = [UIImage imageNamed:@"icon_face_detail"];
        self.detailsTextView.text = @"This is the place for details";
        self.detailsTextView.textColor = [UIColor lightGrayColor];
    }
}

// To remove keyboard observer
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

#pragma mark - Helper methods

// New or updated task for UpdatingDelegate protocol
- (TaskObject *)updatedTask {
    TaskObject *updatedTask      = [[TaskObject alloc] init];
    updatedTask.taskText         = self.taskTextField.text;
    updatedTask.savedDate        = [self.dateFormatter dateFromString:self.deadlineLabel.text];
    //if (![self.detailsTextView.text isEqualToString:@"This is the place for details"]) {
        updatedTask.detailedTaskText = self.detailsTextView.text;
    //}
    updatedTask.contactFullName  = self.contactNameButton.titleLabel.text;
    if (self.tempContactImage) {
        updatedTask.contactImage = UIImagePNGRepresentation(self.tempContactImage);
    } else {
        updatedTask.contactImage = UIImagePNGRepresentation([UIImage imageNamed:@"icon_face_master"]);
    }
    if (self.phoneNumbers) {
        updatedTask.phoneNumbers = self.phoneNumbers;
    } else {
        updatedTask.phoneNumbers = @[];
    }
    if (self.passedTask) {
        updatedTask.isDone = self.passedTask.isDone;
        updatedTask.uid = self.passedTask.uid;
    } else {
        updatedTask.uid = [NSString stringWithFormat:@"%d",(unsigned int)arc4random()%12300];
        NSLog(@"TEST MSG: Random UID is %@", updatedTask.uid);
    }
    return updatedTask;
}

// Method for keyboard observer
- (void)keyboardWillShow {
    if (self.datePickerIsShowing){
        [self hideDatePickerCell];
    }
}

// Contacts methods
-(void)chooseNumber{
    if ([self.phoneNumbers count]) {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Please choose the number" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        for (CNLabeledValue *number in self.phoneNumbers) {
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

// DatePicker methods
- (void)showDatePickerCell {
    self.datePickerIsShowing = YES;
    
    [self.tableView beginUpdates];
    
    [self.tableView endUpdates];
    
    self.datePicker.hidden = NO;
    self.datePicker.alpha = 0.0f;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.datePicker.alpha = 1.0f;
        
    }];
}

- (void)hideDatePickerCell {
    
    self.datePickerIsShowing = NO;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.datePicker.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         self.datePicker.hidden = YES;
                     }];
}

#pragma mark - TableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = self.tableView.rowHeight;
    
    if (indexPath.section == 0 && indexPath.row == 2){
        
        height = self.datePickerIsShowing ? 216.0f : 0.0f;
        
    }
    if (indexPath.section == 1 && indexPath.row == 0) {
        if (!self.datePickerIsShowing) {
            height = 170.0f;
        }
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 1){
        self.datePickerHasBeenPressed = 1;
        if (self.datePickerIsShowing){
            [self.taskTextField resignFirstResponder];
            [self.detailsTextView resignFirstResponder];
            [self hideDatePickerCell];
            
        }else {
            [self.taskTextField resignFirstResponder];
            [self.detailsTextView resignFirstResponder];
            [self showDatePickerCell];
        }
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - TextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - TextView delegate
// For dismissing keyboard
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
    }
    return YES;
}


// For placeholder
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"This is the place for details"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"This is the place for details";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

#pragma mark - CNContactPickerDelegate

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact {
    //NSLog(@"TEST MSG: Contact has been selected");
    NSString *fullName = [NSString stringWithFormat:@"%@ %@", contact.givenName, contact.familyName];
    [self.contactNameButton setTitle:fullName forState:UIControlStateNormal];
    if (contact.imageDataAvailable) {
        self.tempContactImage   = [UIImage imageWithData:contact.imageData];
        self.contactImage.image = self.tempContactImage;
    }
    self.phoneNumbers = contact.phoneNumbers;
}

#pragma mark - IBActions

- (IBAction)pickerDateChanged:(UIDatePicker *)sender {
    self.deadlineLabel.text =  [self.dateFormatter stringFromDate:sender.date];
}

// Saving a task by sending a new/updated task to master
- (IBAction)updateTask:(id)sender {
    // Checking for empty inputs
    if ([self.taskTextField.text isEqualToString:@""]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Your task is empty" message:@"Please input a task name before saving" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        // Saving task
        if (self.passedTask) {
            NSLog(@"TEST MSG: Updating task");
            [self.delegate updateTask:[self updatedTask] forRow:self.indexPathForSave];
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            NSLog(@"TEST MSG: Adding new task");
            //NSLog(@"Delegate is %@", self.delegate);
            if ([self.delegate respondsToSelector:@selector(addNewTask:)]) {
                [self.delegate addNewTask:[self updatedTask]];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }
}

// User pressed call icon
- (IBAction)makeCall:(id)sender {
    [self chooseNumber];
}

// User pressed "Assign a contact"
- (IBAction)selectContact:(id)sender {
    CNContactPickerViewController *contactsPicker = [[CNContactPickerViewController alloc] init];
    contactsPicker.delegate = self;
    contactsPicker.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:contactsPicker animated:YES completion:nil];
}

#pragma mark - Application life cycle

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
