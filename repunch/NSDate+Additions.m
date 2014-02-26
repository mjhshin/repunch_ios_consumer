//
//  NSDate+PrettyDate.m
//  Repunch
//
//  Created by Emil Landron on 9/7/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "NSDate+Additions.h"

@implementation NSDate (Additions)

- (BOOL)isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate;
{
    return [self compare:beginDate] != NSOrderedAscending && [self compare:endDate] == NSOrderedAscending;
}

- (BOOL)isGreaterThan:(NSDate*)date
{
    return ([self compare:date]) == NSOrderedDescending;
}

- (NSString *)prettyDate
{
    NSString * prettyTimestamp;
    
    float delta = [self timeIntervalSinceNow] * -1;
    
    if (delta < 60) {
        prettyTimestamp = @"Just now";
    } else if (delta < 120) {
        prettyTimestamp = @"1 minute ago";
    } else if (delta < 3600) {
        prettyTimestamp = [NSString stringWithFormat:@"%d minutes ago", (int) floor(delta/60.0) ];
    } else if (delta < 7200) {
        prettyTimestamp = @"1 hour ago";
    } else if (delta < 86400) {
        prettyTimestamp = [NSString stringWithFormat:@"%d hours ago", (int) floor(delta/3600.0) ];
    } else if (delta < ( 86400 * 2 ) ) {
        prettyTimestamp = @"1 day ago";
    } else if (delta < ( 86400 * 7 ) ) {
        prettyTimestamp = [NSString stringWithFormat:@"%d days ago", (int) floor(delta/86400.0) ];
    } else {
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        
        prettyTimestamp = [NSString stringWithFormat:@"%@", [formatter stringFromDate:self]];
    }
    return prettyTimestamp;
}

+ (NSString *)formattedDateFromStoreHours:(NSString *)dateString
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"HHmm";
	
	NSDate *date = [formatter dateFromString:dateString];
	
	formatter.dateFormat = @"h:mm a";
	
	return [formatter stringFromDate:date];
}

@end
