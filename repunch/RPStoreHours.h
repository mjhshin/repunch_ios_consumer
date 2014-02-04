//
//  RPStoreHours.h
//  Repunch Biz
//
//  Created by Emil on 11/12/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kOpenTime @"kOpenTime"
#define kCloseTime @"kCloseTime"

@interface RPStoreHours : NSObject

@property (nonatomic, readonly) BOOL isOpenAlways;

- (instancetype)initWithStoreHoursArray:(NSArray*)hoursArray;

- (BOOL)isOpenNow;
- (NSArray*)hoursForToday; // returns an array of dictionarys with keys kOpenTime and kCloseTime


@end

/*

JSON Array
 
open_time: string, range "0600" to "0530".
close_time: string, range "0600" to "0530".
day: integer, range 1 to 7. 1 is Sunday, 7 is Saturday.
 
Example:
[{"close_time":"2330","day":3,"open_time":"0630"},{"close_time":"2330","day":2,"open_time":"0630"},{"close_time":"2330","day":1,"open_time":"0630"},{"close_time":"2330","day":7,"open_time":"0630"},{"close_time":"2330","day":6,"open_time":"0630"},{"close_time":"2330","day":5,"open_time":"0630"},{"close_time":"2330","day":4,"open_time":"0630"}]

Special cases:
1. [] -> Hours unspecified
2. [{"day":0}] -> Open 24/7

*/