//
//  ComposeViewController.h
//  Repunch
//
//  Created by Gwendolyn Weston on 6/27/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@class Store;

@interface ComposeMessageViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, retain) Store *storeObject;
@property (nonatomic, retain) PFObject *recipient;
@property (nonatomic, retain) NSDictionary *sendParameters;
@property (nonatomic, retain) NSString *messageType;

@property (weak, nonatomic) IBOutlet UITextView *body;
@property (weak, nonatomic) IBOutlet UITextField *subject;
@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;
@property (weak, nonatomic) IBOutlet UILabel *storeName;
@property (weak, nonatomic) IBOutlet UIView *toolbar;

- (IBAction)sendFeedback:(id)sender;
- (IBAction)closeButton:(id)sender;

@end
