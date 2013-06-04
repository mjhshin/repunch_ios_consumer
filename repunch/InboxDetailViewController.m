//
//  InboxDetailViewController.m
//  repunch
//
//  Created by CambioLabs on 4/24/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import "InboxDetailViewController.h"
#import "AppDelegate.h"
#import "NSDate+whenString.h"
#import "ComposeViewController.h"

@interface InboxDetailViewController ()

@end

@implementation InboxDetailViewController

@synthesize message;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if (![message.is_read boolValue]) {
        [[PFQuery queryWithClassName:@"Message"] getObjectInBackgroundWithId:message.objectId block:^(PFObject *object, NSError *error){
            [object setObject:[NSNumber numberWithBool:YES] forKey:@"is_read"];
            [message setIs_read:[NSNumber numberWithBool:YES]];
            
            [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
            
            int currentBadgeCount = [[UIApplication sharedApplication] applicationIconBadgeNumber];
            if (currentBadgeCount > 0) {
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:(currentBadgeCount - 1)];
            }
        }];
    }
    
    self.navigationItem.title = [message subject];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIView *firstLineView = [[[UIView alloc] initWithFrame:CGRectMake(15, 15, self.view.frame.size.width - 30, 30)] autorelease];
    
    UILabel *fromLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 30, 20)] autorelease];
    [fromLabel setFont:[UIFont boldSystemFontOfSize:16]];
//    [fromLabel setBackgroundColor:[UIColor blueColor]];
    
    [firstLineView addSubview:fromLabel];
    [self.view addSubview:firstLineView];
    
    UIImage *typeImage = nil;
    NSString *secondLineString = @"";
    
    if ([message.type isEqualToString:@"info"]) {
        
        typeImage = [UIImage imageNamed:@"ico_message_info"];
        [fromLabel setText:message.retailer_name];
        
    } else if ([message.type isEqualToString:@"gift"]) {
        
        typeImage = [UIImage imageNamed:@"ico_message_gift"];
        [fromLabel setText:message.gift_sender_name];
        secondLineString = @"Gift Title";
        
    } else if ([message.type isEqualToString:@"coupon"]) {
        
        typeImage = [UIImage imageNamed:@"ico_message_coupon"];
        [fromLabel setText:message.retailer_name];
        secondLineString = message.coupon_title;
        
    } else if ([message.type isEqualToString:@"reply"]) {
        
        // would this get called? does the type change when a reply is added? or do we just check for reply body/sent time
        typeImage = [UIImage imageNamed:@"ico_message_reply"];
        
    }
    
    UILabel *dateLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, fromLabel.frame.origin.y + fromLabel.frame.size.height, self.view.frame.size.width - 30, 15)] autorelease];
    [dateLabel setFont:[UIFont systemFontOfSize:14]];
    [dateLabel setTextColor:[UIColor grayColor]];
    [dateLabel setText:[message.sent_time whenString]];
//    [dateLabel setBackgroundColor:[UIColor orangeColor]];
    [firstLineView addSubview:dateLabel];
    
    UIView *dateBorder = [[UIView alloc] initWithFrame:CGRectMake(15, firstLineView.frame.origin.y + firstLineView.frame.size.height + 15, self.view.frame.size.width - 30, 1)];
    [dateBorder setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:dateBorder];
    
    UIView *secondLineView = [[[UIView alloc] initWithFrame:CGRectMake(15, dateBorder.frame.origin.y + dateBorder.frame.size.height, self.view.frame.size.width - 30, typeImage.size.height + 10)] autorelease];
    
    UIImageView *typeImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, secondLineView.frame.size.height / 2 - typeImage.size.height / 2, typeImage.size.width, typeImage.size.height)] autorelease];
    [typeImageView setImage:typeImage];
    
    UILabel *secondLineLabel = [[[UILabel alloc] initWithFrame:CGRectMake(typeImageView.frame.origin.x + typeImageView.frame.size.width + 5, 0, secondLineView.frame.size.width - typeImageView.frame.size.width, secondLineView.frame.size.height)] autorelease];
    [secondLineLabel setText:secondLineString];
    
    [secondLineView addSubview:typeImageView];
    [secondLineView addSubview:secondLineLabel];
    
    UIView *secondLineBorder = [[[UIView alloc] initWithFrame:CGRectMake(15, secondLineView.frame.origin.y + secondLineView.frame.size.height, secondLineView.frame.size.width, 1)] autorelease];
    [secondLineBorder setBackgroundColor:[UIColor grayColor]];
    
    float messageViewTop = dateBorder.frame.origin.y + dateBorder.frame.size.height + 15;
    if (![secondLineString isEqualToString:@""]) {
        [self.view addSubview:secondLineView];
        [self.view addSubview:secondLineBorder];
        
        messageViewTop = secondLineBorder.frame.origin.y + secondLineBorder.frame.size.height + 15;
    }
    
    UITextView *messageView = [[UITextView alloc] initWithFrame:CGRectMake(15, messageViewTop, self.view.frame.size.width - 30, self.view.frame.size.height - 49 - 44 - messageViewTop - 15)];
    [messageView setEditable:NO];
    [messageView setContentInset:UIEdgeInsetsMake(-11, -8, 0, 0)];
    [messageView setContentMode:UIViewContentModeScaleAspectFill];
    [messageView setFont:[UIFont systemFontOfSize:17]];
    [messageView setText:[message body]];
//    [messageView setBackgroundColor:[UIColor yellowColor]];
    [messageView sizeToFit];
    [self.view addSubview:messageView];
    
    UIToolbar *messageActionToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 88, self.view.frame.size.width, 44)];
//    [messageActionToolbar setBackgroundImage:[UIImage imageNamed:@"bkg_header"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    [messageActionToolbar setBarStyle:UIBarStyleBlack];
    
    
    UIImage *replyImage = [UIImage imageNamed:@"btn-reply"];
    UIButton *replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [replyButton setFrame:CGRectMake(0, 0, replyImage.size.width, replyImage.size.height)];
    [replyButton setImage:replyImage forState:UIControlStateNormal];
    [replyButton addTarget:self action:@selector(replyMessage) forControlEvents:UIControlEventTouchUpInside];
    [replyButton setTitle:@"Reply" forState:UIControlStateNormal];
    
    UIBarButtonItem *replyItem = [[[UIBarButtonItem alloc] initWithCustomView:replyButton] autorelease];
    
    UIImage *deleteImage = [UIImage imageNamed:@"btn-delete"];
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setFrame:CGRectMake(0, 0, deleteImage.size.width, deleteImage.size.height)];
    [deleteButton setImage:deleteImage forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deleteMessage) forControlEvents:UIControlEventTouchUpInside];
    [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
    
    UIBarButtonItem *deleteItem = [[[UIBarButtonItem alloc] initWithCustomView:deleteButton] autorelease];
    
    UIBarButtonItem *flex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    
    // TODO: set items again after reply or something so the reply button is gone
    NSMutableArray *itemArray = [NSMutableArray arrayWithObject:flex];
    if ([message.type isEqualToString:@"gift"] && message.reply_body == nil) {
        [itemArray addObject:replyItem];
    }    
    [itemArray addObject:deleteItem];
    
    [messageActionToolbar setItems:itemArray];
    [self.view addSubview:messageActionToolbar];
    
}

- (void)replyMessage
{
    ComposeViewController *cvc = [[ComposeViewController alloc] init];
    [cvc setComposeType:@"reply"];
    [cvc setMessageToReply:message];
    [cvc.view setFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height + 44)];
    [self.navigationController.view addSubview:cvc.view];
}

- (void)deleteMessage
{
    UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"Confirm Delete" message:@"Delete this message?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil] autorelease];
    [av show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"button pressed: %d",buttonIndex);
    
    if (buttonIndex == 0) {        
        // cancel button, do nothing
    } else if (buttonIndex == 1) {
        // delete the message
        PFQuery *messageQuery = [PFQuery queryWithClassName:@"Message"];
        
        [messageQuery getObjectInBackgroundWithId:[message objectId] block:^(PFObject *object, NSError *error){
            if (error) {
                NSLog(@"get message to delete error: %@", error);
            } else {
                [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                    if (error) {
                        NSLog(@"error deleting message: %@", error);
                    } else {
                        [message MR_deleteInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
                        
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }];
            }
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [ad makeTabBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [ad makeTabBarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
