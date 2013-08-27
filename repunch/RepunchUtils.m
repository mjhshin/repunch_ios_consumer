//
//  RepunchUtils.m
//  RepunchConsumer
//
//  Created by Michael Shin on 8/26/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "RepunchUtils.h"

@implementation RepunchUtils

+ (void) showDefaultErrorMessage
{
	SIAlertView *errorDialogue = [[SIAlertView alloc] initWithTitle:@"Error"
														 andMessage:@"There was a problem connecting to Repunch. Please check your connection and try again."];
	[errorDialogue addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
	[errorDialogue show];
}

@end
