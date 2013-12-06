//
//  RPStoreHours.m
//  Repunch Biz
//
//  Created by Emil on 11/12/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "RPStoreHours.h"
#import "NSDate+Additions.h"


@interface RPStoreHours ()
@property (strong, nonatomic) NSCalendar *calendar;
@property (strong, nonatomic) NSMutableDictionary *days;
@property (assign, nonatomic) NSCalendarUnit calendarMasks;
@property (strong, nonatomic) NSDateComponents *todayComponent;
@property (strong, nonatomic) NSArray *todayHours;
@property (strong, nonatomic) NSDateFormatter *inFormat;
@end

@implementation RPStoreHours

- (instancetype)initWithStoreHoursArray:(NSArray*)daysArray;
{
    // if there is no days set just return nil
    if (!daysArray) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        
        self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        self.calendarMasks = NSWeekdayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        self.inFormat = [[NSDateFormatter alloc] init];
        self.inFormat.dateFormat = @"HHmm";

        [self organizeDays:daysArray];
    }
    return self;
}

- (void)organizeDays:(NSArray*)daysArray
{
    if (!daysArray) {
        self.days = nil;
        return;
    }
    
    
    NSDictionary *allDay = [daysArray lastObject];
    
    if (allDay){
        NSInteger dayNum = [allDay[@"day"] integerValue];
        if (dayNum == 0 ) {
            _isOpenAlways = YES;
            return;
        }
    }
    
    
    // takes into account repunch dates, open date is in range then increments its weekday
    NSDate *extendedStartDate = [self.inFormat dateFromString:@"0000"];
    NSDate *extendedFinalDate = [self.inFormat dateFromString:@"0531"];
    
    for (NSDictionary *day in daysArray) {
        
        if (!self.days) {
            self.days = [NSMutableDictionary dictionary];
        }
        
        // Convert string day[day] into an int then to a NSNumber then back to string, this will trim any spaces on day[day]
   
    
        NSDate *openTime = [self.inFormat dateFromString:day[@"open_time"]];
        NSDate *closeTime = [self.inFormat dateFromString:day[@"close_time"]];
        
        BOOL isRepunchTime = [openTime isBetweenDate:extendedStartDate andDate:extendedFinalDate];
        
        NSInteger weekdayInt = [day[@"day"] integerValue];
        weekdayInt           = weekdayInt + ((isRepunchTime) ? 1 : 0);
        
        if (weekdayInt >= 8) {
            weekdayInt = (weekdayInt % 8) + 1; // skip index 0;
        }
        
        NSString *weekday = [@(weekdayInt) stringValue];
    
        // Check if there is an array of hours for that day, if not then instantiate one
        if (!self.days[weekday] ) {
            self.days[weekday] = [NSMutableArray array];
        }
        // add open close hours to that day hours array
        
        [self.days[weekday] addObject:@{kOpenTime: openTime, kCloseTime: closeTime}];
    }
}


#pragma mark - Date Fixer

- (NSDictionary*)fixOpenClose:(NSDictionary*)hours forDate:(NSDate*)date
{
    NSDateComponents *openComponents = [self normalizedComponetsFromDate:hours[kOpenTime] withDate:date];
    NSDateComponents *closeComponents = [self normalizedComponetsFromDate:hours[kCloseTime] withDate:date];
    
    NSDate *openTime = [self.calendar dateFromComponents:openComponents];
    NSDate *closeTime = [self.calendar dateFromComponents:closeComponents];
    
    if (![closeTime isGreaterThan:openTime]) {
        // close date is less or equal than open date, then closes next day
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        [offsetComponents setDay:1];
        closeTime = [self.calendar dateByAddingComponents:offsetComponents toDate: closeTime options:0];
    }
    
    return @{kOpenTime: openTime, kCloseTime: closeTime};
}

- (NSDateComponents*)normalizedComponetsFromDate:(NSDate*)toNormalize withDate:(NSDate*)date
{
    NSDateComponents *components = [self.calendar components:self.calendarMasks fromDate:date];
    NSDateComponents *componentsToNormalize =  [self.calendar components:self.calendarMasks fromDate:toNormalize];
    
    [componentsToNormalize setYear:[components year]];
    [componentsToNormalize setMonth:[components month]];
    [componentsToNormalize setDay:[components day]];
    [componentsToNormalize setSecond:0];
    
    return componentsToNormalize;
}

- (NSDateComponents*)normalizedDateComponentsFromString:(NSString*)toNormalize withDate:(NSDate*)date
{
    NSDate *newDate = [self.inFormat dateFromString:toNormalize];
    return [self normalizedComponetsFromDate:newDate withDate:date];
}
- (NSDate*)normalizedDateFromString:(NSString*)toNormalize withDate:(NSDate*)date
{
    NSDate *newDate = [self.inFormat dateFromString:toNormalize];
    return [self normalizedDateFromDate:newDate withDate:date];
}

-(NSDate *)normalizedDateFromDate:(NSDate *)toNormalize withDate:(NSDate *)date
{
    NSDateComponents *components = [self normalizedComponetsFromDate:toNormalize withDate:date];
    return [self.calendar dateFromComponents:components];
}

#pragma mark - Getter

- (NSArray*)hoursForToday
{
    // Only re-calculate dates if today is different from last calcualted date
    
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:-1];
    
    NSDate *now = [NSDate date];
    NSDate *repunchOpenDate = [self normalizedDateFromString:@"0600" withDate:now];
    
    if ([repunchOpenDate isGreaterThan:now]) {
        // if today is less than 6am then today is still yesterday
        now = [self.calendar dateByAddingComponents:offsetComponents toDate: now options:0];
        repunchOpenDate = [self normalizedDateFromString:@"0600" withDate:now];
    }
    
    NSDateComponents *todayComponents = [self.calendar components:self.calendarMasks fromDate:now];

    if (self.todayComponent && self.todayHours && self.todayComponent.weekday == todayComponents.weekday) {
        return [self.todayHours copy];
    }
    self.todayComponent = todayComponents;
    
    [offsetComponents setDay:1];
    NSDate *tomorrow = [self.calendar dateByAddingComponents:offsetComponents toDate: now options:0];
    NSDate *repunchCloseDate = [self normalizedDateFromString:@"0531" withDate:tomorrow];
    
    NSDateComponents *tomorrowComponents = [self.calendar components:self.calendarMasks fromDate:tomorrow];

    NSArray *todayHours = [self hoursForWeekday: todayComponents.weekday];
    NSArray *tomorrowHours = [self hoursForWeekday: tomorrowComponents.weekday];

    NSUInteger hoursCount = todayHours.count + tomorrowHours.count;
    NSMutableArray *fixedTodayHours = nil;
    
    // Fix today's hours
    for (NSDictionary *hours in  todayHours) {
        
        NSDictionary *fixedHours = [self fixOpenClose:hours forDate:now];
       
        NSDate *open = fixedHours[kOpenTime];
        if ([open isBetweenDate:repunchOpenDate andDate:repunchCloseDate]) {
            
            if (!fixedTodayHours) {
                fixedTodayHours = [NSMutableArray arrayWithCapacity:hoursCount];
            }
            
            [fixedTodayHours addObject:fixedHours];
        }
    }
    
    
    // tomorrow is taken into account to fix repunch hours
    for (NSDictionary *hours in  tomorrowHours) {
        
        NSDictionary *fixedHours = [self fixOpenClose:hours forDate:tomorrow];
        
        NSDate *open = fixedHours[kOpenTime];
        
        if ([open isBetweenDate:repunchOpenDate andDate:repunchCloseDate]) {
            
            if (!fixedTodayHours) {
                fixedTodayHours = [NSMutableArray arrayWithCapacity:hoursCount];
            }
            
            [fixedTodayHours addObject:fixedHours];
        }
    }
    
    [fixedTodayHours sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDate *open1 = ((NSDictionary*)obj1)[kOpenTime];
        NSDate *open2 = ((NSDictionary*)obj2)[kOpenTime];
        return [open1 compare:open2];
    }];
    
    self.todayHours = fixedTodayHours;
    return [self.todayHours copy];
}

-(BOOL)isOpenNow
{
    NSArray *dates = [self hoursForToday];
    BOOL isOpen = NO;
    NSDate *now = [NSDate date];
    
    for (NSDictionary * hours in dates) {
       
        NSDate *open = hours[kOpenTime];
        NSDate *close = hours[kCloseTime];
        
        if (!isOpen && [now isBetweenDate:open andDate:close] ) {
            // !isOpen prevents overwrite to NO if date date is not in range
            isOpen = YES;
        }
    }
    
    return isOpen;
}


#pragma mark - Private Getter

- (NSArray*)hoursForWeekday:(NSInteger)weekday
{
    NSString *key = [@(weekday) stringValue];
    NSMutableArray *hours = self.days[key];
    return [hours copy];
}


@end
