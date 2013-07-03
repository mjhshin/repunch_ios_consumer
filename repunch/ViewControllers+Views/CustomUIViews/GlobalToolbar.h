//
//  GlobalToolbar.h
//  repunch
//
//  Created by CambioLabs on 3/29/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GlobalToolbarDelegate 
- (void)openSettings;
- (void)openSearch;
-(void)showPunchCode;
@end

@interface GlobalToolbar : UIToolbar

@property (nonatomic, assign) id<GlobalToolbarDelegate> toolbarDelegate;

@end
