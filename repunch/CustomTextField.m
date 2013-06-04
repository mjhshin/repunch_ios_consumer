//
//  CustomTextField.m
//  repunch
//
//  Created by CambioLabs on 5/13/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import "CustomTextField.h"
#import <QuartzCore/QuartzCore.h>

@implementation CustomTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        [self setTextColor:[UIColor blackColor]];
        [self setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [self.layer setCornerRadius:6];
        [self setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    }
    return self;
}

// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 10 , 10 );
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 10 , 10 );
}

@end
