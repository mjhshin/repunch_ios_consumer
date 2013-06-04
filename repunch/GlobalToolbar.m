//
//  GlobalToolbar.m
//  repunch
//
//  Created by CambioLabs on 3/29/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import "GlobalToolbar.h"

@implementation GlobalToolbar

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setBackgroundImage:[UIImage imageNamed:@"bkg_header"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        
        UIBarButtonItem *flex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
        
        UIImage *settingsImage = [UIImage imageNamed:@"ico-settings"];
        UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [settingsButton setFrame:CGRectMake(0, 0, settingsImage.size.width, settingsImage.size.height)];
        [settingsButton setImage:settingsImage forState:UIControlStateNormal];
        [settingsButton addTarget:self action:@selector(openSettings) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *settingsButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:settingsButton] autorelease];
        
        
        UIImageView *logoImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"repunch-logo"]] autorelease];
        UIBarButtonItem *logo = [[[UIBarButtonItem alloc] initWithCustomView:logoImageView] autorelease];
        
        
        UIImage *searchImage = [UIImage imageNamed:@"ico-search"];
        UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [searchButton setFrame:CGRectMake(0, 0, searchImage.size.width, searchImage.size.height)];
        [searchButton setImage:searchImage forState:UIControlStateNormal];
        [searchButton addTarget:self action:@selector(openSearch) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *searchButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:searchButton] autorelease];
                                         
        [self setItems:[NSArray arrayWithObjects:settingsButtonItem,flex,logo,flex,searchButtonItem,nil]];
    }
    return self;
}

- (void)openSettings
{
    [delegate openSettings];
}

- (void)openSearch
{
    [delegate openSearch];
}

@end
