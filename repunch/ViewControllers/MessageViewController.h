//
//  MessageViewController.h
//  Repunch
//
//  Created by Gwendolyn Weston on 6/26/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalDelegate.h"
#import <Parse/Parse.h>

@interface MessageViewController : UIViewController
@property (nonatomic, retain) id<ModalDelegate> modalDelegate;
@property (nonatomic, retain)  PFObject *message; //ONLY TEMPORARY. WILL REPLACE WITH MESSAGE ENTITY.
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *senderLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;

@end
