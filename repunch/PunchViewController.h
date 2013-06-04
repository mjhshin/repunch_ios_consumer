//
//  PunchViewController.h
//  repunch
//
//  Created by CambioLabs on 3/22/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PunchViewController : UIViewController
{
    UIImageView *bumpDiagram;
    BOOL bumpIsConnected;
}

@property (nonatomic, retain) UIImageView *bumpDiagram;
@property (nonatomic, readwrite) BOOL bumpIsConnected;

@end
