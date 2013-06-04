//
//  ComposeViewController.h
//  repunch
//
//  Created by CambioLabs on 5/14/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reward.h"
#import "Retailer.h"
#import "Message.h"
#import <Parse/Parse.h>

@interface ComposeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>
{
    UITableView *composeTableView;
    NSString *composeType;
    NSString *subject;
    PFUser *recipient;
    Reward *reward;
    Retailer *place;
    
    UITextView *messageTextView;
    NSString *messagePlaceholderText;
    
    Message *messageToReply;
    
    UIViewController *parentVC;
}

@property (nonatomic, retain) UITableView *composeTableView;
@property (nonatomic, retain) NSString *composeType;
@property (nonatomic, retain) NSString *subject;
@property (nonatomic, retain) PFUser *recipient;
@property (nonatomic, retain) Reward *reward;
@property (nonatomic, retain) Retailer *place;
@property (nonatomic, retain) UITextView *messageTextView;
@property (nonatomic, retain) NSString *messagePlaceholderText;
@property (nonatomic, retain) Message *messageToReply;
@property (nonatomic, retain) UIViewController *parentVC;

@end
