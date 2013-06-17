//
//  RewardDetailViewController.m
//  repunch
//
//  Created by CambioLabs on 4/2/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import "RewardDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "FriendViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "User.h"
#import "AppDelegate.h"

#define SHARE_AV_TAG 0
#define FB_REQ_AV_TAG 1

@interface RewardDetailViewController ()

@end

@implementation RewardDetailViewController

@synthesize bumpDiagram, reward, bumpIsConnected, parentVC, placePunchesLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor colorWithRed:150/255.f green:150/255.f blue:150/255.f alpha:.8]];
    
    UIView *contentView = [[[UIView alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, self.view.frame.size.height - 70)] autorelease];
    [contentView setBackgroundColor:[UIColor whiteColor]];
    [contentView.layer setCornerRadius:6];
    [self.view addSubview:contentView];
    
    UIView *contentViewHeader = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, contentView.frame.size.width, 60)] autorelease];
    [contentViewHeader setBackgroundColor:[UIColor colorWithRed:244/255.f green:244/255.f blue:244/255.f alpha:1]];
    [contentViewHeader.layer setCornerRadius:6];
    [contentView addSubview:contentViewHeader];
    
    UILabel *rewardRequirementLabel = [[[UILabel alloc] initWithFrame:CGRectMake(15, 18, 200, 24)] autorelease];
    [rewardRequirementLabel setText:[NSString stringWithFormat:([[self.reward required] integerValue] == 1 ? @"%@ Punch" :  @"%@ Punches"),[self.reward required]]];
    [rewardRequirementLabel setFont:[UIFont systemFontOfSize:18]];
    [rewardRequirementLabel setNumberOfLines:0];
    [rewardRequirementLabel sizeToFit];
    [rewardRequirementLabel setBackgroundColor:[UIColor clearColor]];
    [contentViewHeader addSubview:rewardRequirementLabel];
    
    UIImage *closeRewardImage = [UIImage imageNamed:@"btn_x-gray"];
    UIButton *closeRewardDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeRewardDetailButton setImage:closeRewardImage forState:UIControlStateNormal];
    [closeRewardDetailButton setFrame:CGRectMake(contentViewHeader.frame.size.width - closeRewardImage.size.width - 15, 12, closeRewardImage.size.width, closeRewardImage.size.height)];
    [closeRewardDetailButton addTarget:self action:@selector(closeRewardDetail) forControlEvents:UIControlEventTouchUpInside];
    [contentViewHeader addSubview:closeRewardDetailButton];
    
    UIView *contentViewHeaderBorder = [[[UIView alloc] initWithFrame:CGRectMake(0, contentViewHeader.frame.size.height-6, contentView.frame.size.width, 1)] autorelease];
    [contentViewHeaderBorder setBackgroundColor:[UIColor colorWithRed:231/255.f green:231/255.f blue:231/255.f alpha:1]];
    [contentView addSubview:contentViewHeaderBorder];
    
    UIScrollView *mainContentView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, contentViewHeaderBorder.frame.origin.y + 1, contentView.frame.size.width, contentView.frame.size.height - contentViewHeaderBorder.frame.origin.y - 1)] autorelease];
    [mainContentView.layer setCornerRadius:6];
    [mainContentView setBackgroundColor:[UIColor whiteColor]];
    [contentView addSubview:mainContentView];
    
    UILabel *rewardNameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 10, mainContentView.frame.size.width - 20, 25)] autorelease];
    [rewardNameLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [rewardNameLabel setText:[self.reward name]];
    [rewardNameLabel setNumberOfLines:0];
    [rewardNameLabel sizeToFit];
    [mainContentView addSubview:rewardNameLabel];
    
    UILabel *rewardDetailsLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, rewardNameLabel.frame.origin.y + rewardNameLabel.frame.size.height, mainContentView.frame.size.width - 20, 50)] autorelease];
    [rewardDetailsLabel setFont:[UIFont italicSystemFontOfSize:12]];
    [rewardDetailsLabel setTextColor:[UIColor colorWithRed:50/255.f green:50/255.f blue:50/255.f alpha:1]];
    [rewardDetailsLabel setText:[self.reward reward_description]];
    [rewardDetailsLabel setNumberOfLines:0];
    [rewardDetailsLabel sizeToFit];
    [mainContentView addSubview:rewardDetailsLabel];
    
    placePunchesLabel = [[[UILabel alloc] init] autorelease];
    placePunchesLabel.font = [UIFont boldSystemFontOfSize:14];
    [mainContentView addSubview:placePunchesLabel];
    
    UIImageView *placePunchesImageView = [[[UIImageView alloc] init] autorelease];
    [mainContentView addSubview:placePunchesImageView];
    
    UIImage *punchImage = [UIImage imageNamed:([self.reward.place.num_punches integerValue] == 0 ? @"ico_starburst-gray" : @"ico_starburst-orange")];
    [placePunchesImageView setImage:punchImage];
    [placePunchesImageView setFrame:CGRectMake(10, rewardDetailsLabel.frame.origin.y + rewardDetailsLabel.frame.size.height + 10, punchImage.size.width, punchImage.size.height)];
    
    [placePunchesLabel setText:[NSString stringWithFormat:([self.reward.place.num_punches integerValue] == 1 ? @"%@ Punch" :  @"%@ Punches"),self.reward.place.num_punches]];
    [placePunchesLabel setFrame:CGRectMake(placePunchesImageView.frame.origin.x + placePunchesImageView.frame.size.width + 2, placePunchesImageView.frame.origin.y + placePunchesImageView.frame.size.height / 2 - 9, 150, 18)];
    [placePunchesLabel sizeToFit];
    
    UIImage *bump1 = [UIImage imageNamed:@"bump_diagram"];
    float imgFactor = bump1.size.height / bump1.size.width;
    
    bumpDiagram = [[UIImageView alloc] initWithFrame:CGRectMake(10, placePunchesImageView.frame.origin.y + placePunchesImageView.frame.size.height, mainContentView.frame.size.width - 20, (mainContentView.frame.size.width - 20) * imgFactor)];
    [bumpDiagram setContentMode:UIViewContentModeScaleAspectFit];
    [bumpDiagram setAnimationImages:[NSArray arrayWithObjects:[UIImage imageNamed:@"bump_diagram2"], bump1, nil]];
    [bumpDiagram setAnimationDuration:4.0];
    [bumpDiagram setContentMode:UIViewContentModeScaleAspectFill];
    [mainContentView addSubview:bumpDiagram];
    
    UILabel *rewardBumpLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, bumpDiagram.frame.origin.y + bumpDiagram.frame.size.height, mainContentView.frame.size.width - 20, 18)] autorelease];
    [rewardBumpLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [rewardBumpLabel setTextAlignment:NSTextAlignmentCenter];
    [rewardBumpLabel setText:@"Bump to redeem"];
    [mainContentView addSubview:rewardBumpLabel];
    
    UILabel *rewardBumpInstructions = [[[UILabel alloc] initWithFrame:CGRectMake(10, rewardBumpLabel.frame.origin.y + rewardBumpLabel.frame.size.height, mainContentView.frame.size.width - 20, 36)] autorelease];
    [rewardBumpInstructions setFont:[UIFont systemFontOfSize:12]];
    [rewardBumpInstructions setTextColor:[UIColor colorWithRed:100/255.f green:100/255.f blue:100/255.f alpha:1]];
    [rewardBumpInstructions setText:@"To redeem this reward, gently bump the cashier's smartphone with yours."];
    [rewardBumpInstructions setNumberOfLines:0];
    [rewardBumpInstructions setTextAlignment:NSTextAlignmentCenter];
//    [rewardBumpInstructions sizeToFit];
    [mainContentView addSubview:rewardBumpInstructions];
    
    UIButton *rewardGiftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rewardGiftButton addTarget:self action:@selector(sendGift) forControlEvents:UIControlEventTouchUpInside];
    [rewardGiftButton setTitle:@"Gift This Reward" forState:UIControlStateNormal];
    [rewardGiftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rewardGiftButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [rewardGiftButton setImage:[UIImage imageNamed:@"ico_gift"] forState:UIControlStateNormal];
    [rewardGiftButton setFrame:CGRectMake(10, rewardBumpInstructions.frame.origin.y + rewardBumpInstructions.frame.size.height + 20, mainContentView.frame.size.width - 20, 44)];
    [rewardGiftButton.layer setBorderColor:[[UIColor colorWithRed:225/255.f green:225/255.f blue:225/255.f alpha:1] CGColor]];
    [rewardGiftButton.layer setBorderWidth:1];
    [rewardGiftButton.layer setCornerRadius:6];
    [rewardGiftButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -160, 0, 0)];
    [rewardGiftButton setImageEdgeInsets:UIEdgeInsetsMake(0, 230, 0, 0)];
    [mainContentView addSubview:rewardGiftButton];
    
    [mainContentView setContentSize:CGSizeMake(contentView.frame.size.width, rewardGiftButton.frame.origin.y + rewardGiftButton.frame.size.height + 10)];
    
    UIButton *redeemButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [redeemButton setFrame:CGRectMake(0, 0, 80, 40)];
    [redeemButton addTarget:self action:@selector(doBump) forControlEvents:UIControlEventTouchUpInside];
    [redeemButton setTitle:@"Bump" forState:UIControlStateNormal];
    #if TARGET_IPHONE_SIMULATOR
//    [mainContentView addSubview:redeemButton];
    #endif
    
    self.bumpIsConnected = NO;
}
- (void)completeRedeem
{
    if ([[PFFacebookUtils session] isOpen]) {
        // TODO: need real punch number for sharing
        int sharePunches = 1;
        
        UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"Success" message:[NSString stringWithFormat:@"Successfully redeemed \"%@\". Share on Facebook to receive %d %@?", reward.name, sharePunches, (sharePunches == 1 ? @"punch" : @"punches")] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] autorelease];
        [av setTag:SHARE_AV_TAG];
        [av show];
    } else {
        UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"Success" message:[NSString stringWithFormat:@"Successfully redeemed \"%@\"",reward.name] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] autorelease];
        [av show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"button pressed: %d",buttonIndex);
    
    if (alertView.tag == FB_REQ_AV_TAG) {
        // do some stuff
        if (buttonIndex == 0) {
            // do nothing
        } else {
            PFUser *user = [PFUser currentUser];
            NSArray *permissionsArray = @[ @"user_about_me", @"email", @"user_relationships", @"user_birthday", @"user_location"];
            
            if (![PFFacebookUtils isLinkedWithUser:user]) {
                [PFFacebookUtils linkUser:user permissions:permissionsArray block:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"Woohoo, user logged in with Facebook!");
                        [self performSelector:@selector(sendGift)];
                    }
                    
                    if (error) {
                        NSLog(@"error linking account: %@",error);
                    }
                }];
            }
        }
        
        
        return;
    }
    
    if (buttonIndex == 0) {
        // just close this view
        
        [parentVC viewWillAppear:NO];
        [self.view removeFromSuperview];
    } else if (buttonIndex == 1) {
        // do fb stuff
        
        [PFFacebookUtils reauthorizeUser:[PFUser currentUser] withPublishPermissions:@[@"publish_stream"] audience:FBSessionDefaultAudienceFriends block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                // Your app now has publishing permissions for the user
                
                // TODO: need full share text
                FBRequest *request = [FBRequest requestForPostStatusUpdate:[NSString stringWithFormat:@"I just got \"%@\" from %@ with Repunch!",reward.name, reward.place.name]];
                
                [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error){
                    NSLog(@"Share result: %@",result);
                    if (error) {
                        NSLog(@"Share error: %@",error);
                    } else {
                        NSLog(@"Shared");
                        
                        PFUser *pfuser = [PFUser currentUser];
                        User *localUser = [User MR_findFirstByAttribute:@"username" withValue:[pfuser username]];
                        PFQuery *query = [[pfuser relationforKey:@"my_places"] query];
                        [query whereKey:@"retailer_id" equalTo:reward.place.retailer_id];
                        
                        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
                            if (error) {
                                NSLog(@"Find place error: %@", error);
                            } else {
                                PFObject *thisPFPlace = [objects objectAtIndex:0];
                                
                                // TODO: get real number
                                int sharePunches = 1;
                                int newPunchCount = [[thisPFPlace objectForKey:@"num_punches"] intValue] + sharePunches;
                                
                                [thisPFPlace setObject:[NSNumber numberWithInt:newPunchCount] forKey:@"num_punches"];
                                
                                [thisPFPlace saveInBackgroundWithBlock:^(BOOL succeeded, NSError *saveError){
                                    if (saveError) {
                                        NSLog(@"Redeem save error: %@", saveError);
                                    } else {
                                        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                                        
                                        Retailer *thisPlace = [Retailer MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"retailer_id = %@ and user = %@",reward.place.retailer_id,localUser] inContext:localContext];
                                        
                                        if (thisPlace == nil) {
                                            thisPlace = [Retailer MR_createEntity];
                                        }
                                        
                                        [thisPlace setNum_punches:[NSNumber numberWithInt:newPunchCount]];
                                        
                                        [localContext MR_saveToPersistentStoreAndWait];
                                        
                                        UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"Success" message:[NSString stringWithFormat:@"Successfully shared to Facebook. You have received %d %@ for sharing.",sharePunches, (sharePunches == 1 ? @"punch" : @"punches")] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] autorelease];
                                        [av show];
                                        
                                        [parentVC viewWillAppear:NO];
                                        
                                        [self.view removeFromSuperview];
                                    }
                                }];
                            }
                        }];
                    }
                }];
                
            } else if(error) {
                NSLog(@"Error requesting publishing permissions: %@", error);
            }
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [placePunchesLabel setText:[NSString stringWithFormat:([self.reward.place.num_punches integerValue] == 1 ? @"%@ Punch" :  @"%@ Punches"),self.reward.place.num_punches]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (void)sendGift
{
    if ([[PFFacebookUtils session] isOpen]) {
        FriendViewController *fvc = [[FriendViewController alloc] init];
        [fvc setReward:reward];
        [fvc.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [fvc setParentVC:self];
        [self.view addSubview:fvc.view];
    } else {
        UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"Facebook Required" message:@"Please log in with Facebook to use this feature." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Log In", nil] autorelease];
        [av setTag:FB_REQ_AV_TAG];
        [av show];
    }
}

- (void)closeRewardDetail
{
    [parentVC viewWillAppear:NO];
    [self.view removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
