//
//  ComposeViewController.h
//  Repunch
//
//  Created by Gwendolyn Weston on 6/27/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "DataManager.h"
#import "SIAlertView.h"
#import "GradientBackground.h"
#include <Parse/Parse.h>
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@class Store;

@interface ComposeMessageViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, strong) NSString *storeId;
@property (nonatomic, strong) NSString *messageType;
@property (nonatomic, strong) NSString *recepientName;

@property (weak, nonatomic) IBOutlet UIView *toolbar;
@property (weak, nonatomic) IBOutlet UILabel *storeName;
@property (weak, nonatomic) IBOutlet UITextField *subject;
@property (weak, nonatomic) IBOutlet UITextView *body;
@property (weak, nonatomic) IBOutlet UILabel *bodyPlaceholder;

- (IBAction)sendFeedback:(id)sender;
- (IBAction)closeButton:(id)sender;

@end