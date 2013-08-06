//
//  StoreViewController.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface StoreViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property NSString *storeId;
@property PFObject *store;
@property PFObject *patronStore;
@property BOOL isSavedStore;
@property PFObject *patronStoreObject;
@property BOOL leftoverFBPostExists;

//UI STUFF
@property (weak, nonatomic) IBOutlet UIView *toolbar;
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
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

- (IBAction)callButton:(id)sender;
- (IBAction)mapButton:(id)sender;
- (IBAction)feedbackButton:(id)sender;
- (IBAction)addStore:(id)sender;
- (IBAction)deleteStore:(id)sender;
- (IBAction)closeView:(id)sender;

@property (strong, nonatomic) IBOutlet UITableView *rewardsTable;

@end
