//
//  InboxViewController.h
//  repunch
//
//  Created by CambioLabs on 3/22/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InboxViewController : UITableViewController{
    NSMutableArray *inboxData;
}

@property (nonatomic, retain) NSMutableArray *inboxData;

@end
