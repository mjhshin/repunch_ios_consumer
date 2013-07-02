//
//  ComposeViewController.h
//  Repunch
//
//  Created by Gwendolyn Weston on 6/27/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalDelegate.h"

@class Store;

@interface ComposeViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, retain) id<ModalDelegate> modalDelegate;
@property (nonatomic, retain) Store* storeObject;
@property (weak, nonatomic) IBOutlet UITextView *body;
@property (weak, nonatomic) IBOutlet UITextField *subject;

@end
