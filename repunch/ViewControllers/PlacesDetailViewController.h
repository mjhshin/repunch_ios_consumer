//
//  PlacesDetailViewController.h
//  Repunch
//
//  Created by Gwendolyn Weston on 6/19/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

#import "ModalDelegate.h"
#import "Store.h"

@interface PlacesDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, ModalDelegate>

@property (nonatomic, retain) id<ModalDelegate> modalDelegate;
@property (nonatomic, retain) Store* storeObject;
@property BOOL isSavedStore;


//UI STUFF
@property (weak, nonatomic) IBOutlet UIImageView *storePic;
@property (weak, nonatomic) IBOutlet UILabel *storeAddress;
@property (weak, nonatomic) IBOutlet UILabel *storeHours;
@property (weak, nonatomic) IBOutlet UILabel *storeOpen;
@property (weak, nonatomic) IBOutlet UILabel *numPunches;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *feedbackBtn;

- (IBAction)callButton:(id)sender;
- (IBAction)mapButton:(id)sender;
- (IBAction)feedbackButton:(id)sender;

@property (strong, nonatomic) IBOutlet UITableView *rewardsTable;

@end
