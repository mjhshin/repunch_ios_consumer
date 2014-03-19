//
//  RPAnnotationView.m
//  RepunchConsumer
//
//  Created by Michael Shin on 3/17/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import "RPAnnotationView.h"
#import "RepunchUtils.h"

@implementation RPAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
	if (self) {
        [self initAnnotationView];
    }
    return self;
}

- (void)initAnnotationView
{
	self.canShowCallout = YES;
	self.draggable = NO;
	self.image = [UIImage imageNamed:@"annotation_icon"];
	self.centerOffset = CGPointMake(0, -30); //image height 42
	
	UIButton *storeButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	storeButton.tintColor = [RepunchUtils repunchOrangeColor];
	self.rightCalloutAccessoryView = storeButton;
}


+ (NSString *)reuseIdentifier
{
    return NSStringFromClass(self);
}

@end
