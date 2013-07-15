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
@property (weak, nonatomic) IBOutlet UILabel *storeName;
@property (weak, nonatomic) IBOutlet UIImageView *storePic;
@property (weak, nonatomic) IBOutlet UILabel *storeStreet;
@property (weak, nonatomic) IBOutlet UILabel *storeCrossStreets;
@property (weak, nonatomic) IBOutlet UILabel *storeNeighborhood;
@property (weak, nonatomic) IBOutlet UILabel *storeCity;
@property (weak, nonatomic) IBOutlet UILabel *storeHours;
@property (weak, nonatomic) IBOutlet UILabel *storeOpen;
@property (weak, nonatomic) IBOutlet UILabel *numPunches;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *feedbackBtn;
@property (weak, nonatomic) IBOutlet UIButton *addPlaceBtn;
@property (weak, nonatomic) IBOutlet UILabel *feedbackLbl;
@property (weak, nonatomic) IBOutlet UIView *callView;
@property (weak, nonatomic) IBOutlet UIView *mapView;

- (IBAction)callButton:(id)sender;
- (IBAction)mapButton:(id)sender;
- (IBAction)feedbackButton:(id)sender;
- (IBAction)addStore:(id)sender;
- (IBAction)deleteStore:(id)sender;
- (IBAction)closeView:(id)sender;

@property (strong, nonatomic) IBOutlet UITableView *rewardsTable;

@end
