//
//  NSDate+whenString.m
//  repunch
//
//  Created by CambioLabs on 5/22/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//
//  Taken from comments here: http://www.bdunagan.com/2008/09/13/cocoa-tutorial-yesterday-today-and-tomorrow-with-nsdate/
//

#import "NSDate+whenString.h"

@implementation NSDate (whenString)

- (NSDate *)dateWithZeroTime
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:self];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    return [calendar dateFromComponents:comps];
}

- (NSString *)whenString
{
    NSDate *selfZero = [self dateWithZeroTime];
    NSDate *todayZero = [[NSDate date] dateWithZeroTime];
    NSTimeInterval interval = [todayZero timeIntervalSinceDate:selfZero];
    int dayDiff = interval/(60*60*24);
    
    // Initialize the formatter.
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    
    if (dayDiff == 0) { // today: show time only
        [formatter setDateStyle:NSDateFormatterNoStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
    } else if (dayDiff == 1 || dayDiff == -1) {
        //return NSLocalizedString((dayDiff == 1 ? @”Yesterday” : @”Tomorrow”), nil);
        [formatter setDoesRelativeDateFormatting:YES];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterNoStyle];
    } else if (dayDiff <= 7) { // < 1 week ago: show weekday
        [formatter setDateFormat:@"EEEE"];
    } else { // show date
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setTimeStyle:NSDateFormatterNoStyle];
    }
    
    return [formatter stringFromDate:self];
}

@end
