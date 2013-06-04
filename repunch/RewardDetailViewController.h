//
//  RewardDetailViewController.h
//  repunch
//
//  Created by CambioLabs on 4/2/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Reward.h"
#import "Retailer.h"

@interface RewardDetailViewController : UIViewController
{
    UIImageView *bumpDiagram;
    Reward *reward;
    BOOL bumpIsConnected;
    UIViewController *parentVC;
    UILabel *placePunchesLabel;
}

@property (nonatomic, retain) UIImageView *bumpDiagram;
@property (nonatomic, retain) Reward *reward;
@property (nonatomic, readwrite) BOOL bumpIsConnected;
@property (nonatomic, retain) UIViewController *parentVC;
@property (nonatomic, retain) UILabel *placePunchesLabel;

@end
