//
//  FriendViewController.h
//  repunch
//
//  Created by CambioLabs on 5/14/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Retailer.h"
#import "Reward.h"

@interface FriendViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *friendData;
    UITableView *friendTableView;
    NSArray *alphabet;
    Reward *reward;
    
    UIViewController *parentVC;
}

@property (nonatomic, retain) NSMutableArray *friendData;
@property (nonatomic, retain) UITableView *friendTableView;
@property (nonatomic, retain) NSArray *alphabet;
@property (nonatomic, retain) Reward *reward;
@property (nonatomic, retain) UIViewController *parentVC;

@end
