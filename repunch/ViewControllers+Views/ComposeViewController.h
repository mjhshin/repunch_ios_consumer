//
//  ComposeViewController.h
//  Repunch
//
//  Created by Gwendolyn Weston on 6/27/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalDelegate.h"
#import <Parse/Parse.h>

@class Store;

@interface ComposeViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, retain) id<ModalDelegate> modalDelegate;
@property (nonatomic, retain) Store *storeObject;
@property (nonatomic, retain) PFObject *recipient;

@property (nonatomic, retain) NSDictionary *giftParameters;
@property (nonatomic, retain) NSString *messageType;
@property (weak, nonatomic) IBOutlet UITextView *body;
@property (weak, nonatomic) IBOutlet UITextField *subject;
@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;
@property (weak, nonatomic) IBOutlet UILabel *storeName;
- (IBAction)sendFeedback:(id)sender;
- (IBAction)closeButton:(id)sender;

@end
