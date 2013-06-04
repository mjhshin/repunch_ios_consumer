//
//  PunchViewController.m
//  repunch
//
//  Created by CambioLabs on 3/22/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import "PunchViewController.h"
#import "BumpClient.h"
#import "Retailer.h"
#import "User.h"
#import <Parse/Parse.h>

@interface PunchViewController ()

@end

@implementation PunchViewController

@synthesize bumpDiagram, bumpIsConnected;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Punch", @"Punch");
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"ico-tab-punch-selected"] withFinishedUnselectedImage:[UIImage imageNamed:@"ico-tab-punch"]];
        self.bumpIsConnected = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    int instructionHeight = 90;
    UIView *bumpInstructions = [[[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - instructionHeight - 49, self.view.frame.size.width, instructionHeight)] autorelease];
    [bumpInstructions setBackgroundColor:[UIColor colorWithRed:231/255.f green:231/255.f blue:231/255.f alpha:1]];
    [self.view addSubview:bumpInstructions];
    
    bumpDiagram = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - bumpInstructions.frame.size.height - 49)];
    [bumpDiagram setContentMode:UIViewContentModeScaleAspectFit];
    [bumpDiagram setAnimationImages:[NSArray arrayWithObjects:[UIImage imageNamed:@"bump_diagram2"], [UIImage imageNamed:@"bump_diagram"], nil]];
    [bumpDiagram setAnimationDuration:3.0];
//    [bumpDiagram setBackgroundColor:[UIColor colorWithRed:.5 green:0 blue:0 alpha:.5]];
    [self.view addSubview:bumpDiagram];
    
    UIImageView *bumpInfoIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico-info"]] autorelease];
    [bumpInfoIcon setFrame:CGRectMake(20, instructionHeight / 2 - 35/2, 35, 35)];
    [bumpInfoIcon setContentMode:UIViewContentModeScaleAspectFit];
    [bumpInstructions addSubview:bumpInfoIcon];
    
    UILabel *bumpInfoLabel = [[[UILabel alloc] initWithFrame:CGRectMake(75, 2, self.view.frame.size.width - 85, instructionHeight - 40)] autorelease];
    [bumpInfoLabel setNumberOfLines:0];
    [bumpInfoLabel setText:@"Gently bump the cashier's device to get punched. Ask the cashier if you have any questions!"];
    [bumpInfoLabel sizeToFit];
    [bumpInfoLabel setBackgroundColor:[UIColor clearColor]];
    [bumpInfoLabel setTextColor:[UIColor colorWithRed:107/255.f green:109/255.f blue:107/255.f alpha:1]];
    [bumpInstructions addSubview:bumpInfoLabel];
    
    UIButton *bumpButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [bumpButton setFrame:CGRectMake(0, 0, 60, 40)];
    [bumpButton setTitle:@"Bump" forState:UIControlStateNormal];
    [bumpButton addTarget:self action:@selector(doBump) forControlEvents:UIControlEventTouchUpInside];
#if TARGET_IPHONE_SIMULATOR
//    [self.view addSubview:bumpButton];
#endif
    
}

- (void)doBump
{
    [[BumpClient sharedClient] simulateBump];
}

- (void)viewDidAppear:(BOOL)animated
{
    [bumpDiagram startAnimating];
    
//    [[BumpClient sharedClient] connect];
    
    /*[[BumpClient sharedClient] setMatchBlock:^(BumpChannelID channel) {
        NSLog(@"Matched with user: %@", [[BumpClient sharedClient] userIDForChannel:channel]);
        [[BumpClient sharedClient] confirmMatch:YES onChannel:channel];
    }];
    
    [[BumpClient sharedClient] setChannelConfirmedBlock:^(BumpChannelID channel) {
        NSLog(@"Channel with %@ confirmed.", [[BumpClient sharedClient] userIDForChannel:channel]);
        
        NSData *sendData = [NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:[[PFUser currentUser] username],@"username", nil] options:kNilOptions error:nil];
        [[BumpClient sharedClient] sendData:sendData toChannel:channel];
    }];
    
    [[BumpClient sharedClient] setDataReceivedBlock:^(BumpChannelID channel, NSData *data) {
        NSLog(@"Data received from %@: %@",
              [[BumpClient sharedClient] userIDForChannel:channel],
              [NSString stringWithCString:[data bytes] encoding:NSUTF8StringEncoding]);
        
        // TODO: need to verify data received matches what is expected here, to get this to work I set the data sent in the retailer app
        NSDictionary *receivedData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        // TODO: check "Number of separate times a customer can receive punches per day"
        
        PFUser *pfuser = [PFUser currentUser];
        User *localUser = [User MR_findFirstByAttribute:@"username" withValue:[pfuser username]];
        PFQuery *query = [[pfuser relationforKey:@"my_places"] query];
        [query whereKey:@"retailer_id" equalTo:[receivedData objectForKey:@"retailer_id"]];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            if (error) {
                NSLog(@"Find place error: %@", error);
            } else {
                PFObject *thisPFPlace = [objects objectAtIndex:0];
                
                int receivedPunches = [[receivedData objectForKey:@"num_punches"] intValue];
                int newPunchCount = receivedPunches +
                                    [[thisPFPlace objectForKey:@"num_punches"] intValue];
                
                [thisPFPlace setObject:[NSNumber numberWithInt:newPunchCount] forKey:@"num_punches"];
                
                [thisPFPlace saveInBackgroundWithBlock:^(BOOL succeeded, NSError *saveError){
                    if (saveError) {
                        NSLog(@"Punch save error: %@", saveError);
                    } else {
                        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                        
                        Retailer *thisPlace = [Retailer MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"retailer_id = %@ and user = %@",[receivedData objectForKey:@"retailer_id"],localUser] inContext:localContext];
                        if (thisPlace == nil) {
                            thisPlace = [Retailer MR_createInContext:localContext];
                        }
                        
                        [thisPlace setNum_punches:[NSNumber numberWithInt:newPunchCount]];
                        
                        [localContext MR_saveToPersistentStoreAndWait];
                        
                        // TODO: check number for "punch" vs "punches"
                        UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"Success" message:[NSString stringWithFormat:@"You received %d %@ from %@.",receivedPunches,(receivedPunches == 1 ? @"punch" : @"punches"),thisPlace.name] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] autorelease];
                        [av show];
                    }
                }];
            }
        }];

    }];
    
    [[BumpClient sharedClient] setBumpEventBlock:^(bump_event event) {
        switch(event) {
            case BUMP_EVENT_BUMP:
                NSLog(@"Bump detected.");
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                break;
            case BUMP_EVENT_NO_MATCH:
                NSLog(@"No match.");
                break;
        }
    }];
    
    [[BumpClient sharedClient] setConnectionStateChangedBlock:^(BOOL connected) {
        if (connected) {
            NSLog(@"Bump connected...");
            self.bumpIsConnected = YES;
        } else {
            NSLog(@"Bump disconnected...");
            self.bumpIsConnected = NO;
        }
    }];*/
}

- (void)viewDidDisappear:(BOOL)animated
{
    [bumpDiagram stopAnimating];
    
    if (self.bumpIsConnected) {
        [[BumpClient sharedClient] disconnect];
    }
}

- (void)dealloc
{
    [bumpDiagram release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
