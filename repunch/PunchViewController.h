//
//  PunchViewController.h
//  BLE Central
//
//  Created by Michael Shin on 4/8/14.
//  Copyright (c) 2014 Repunch, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PunchViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *storeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *explanationLabel;
@property (weak, nonatomic) IBOutlet UIButton *wrongStoreButton;
@property (weak, nonatomic) IBOutlet UIImageView *loadingImageView;

- (IBAction)wrongStoreButtonAction:(id)sender;

- (void)requestPunch;
- (void)cancelPunchRequest;

@end
