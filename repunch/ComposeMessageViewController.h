//
//  ComposeViewController.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "DataManager.h"
#include <Parse/Parse.h>
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "RepunchUtils.h"

@class ComposeMessageViewController;

@protocol ComposeMessageDelegate <NSObject>
- (void) giftReplySent:(ComposeMessageViewController *)controller;
@end

@interface ComposeMessageViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, weak) id <ComposeMessageDelegate> delegate;

@property (nonatomic, strong) NSString *storeId;
@property (nonatomic, strong) NSString *messageType;
@property (nonatomic, strong) NSString *recepientName;
@property (nonatomic, strong) NSString *giftRecepientId;
@property (nonatomic, strong) NSString *giftTitle;
@property (nonatomic, strong) NSString *giftDescription;
@property NSInteger giftPunches;
@property (nonatomic, strong) NSString *giftReplyMessageId;
@property (nonatomic, strong) NSString *giftMessageStatusId;

@property (weak, nonatomic) IBOutlet UITextField *subject;
@property (weak, nonatomic) IBOutlet UITextView *body;
@property (weak, nonatomic) IBOutlet UILabel *bodyPlaceholder;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end
