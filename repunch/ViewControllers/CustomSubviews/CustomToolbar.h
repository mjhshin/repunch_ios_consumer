//
//  CustomToolbar.h
//  Repunch
//
//  Created by Gwendolyn Weston on 6/27/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomToolbar : UIToolbar
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *middleItem;

@end
