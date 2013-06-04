//
//  InboxDetailViewController.h
//  repunch
//
//  Created by CambioLabs on 4/24/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

@interface InboxDetailViewController : UIViewController{
    Message *message;
}

@property (nonatomic, retain) Message *message;

@end
