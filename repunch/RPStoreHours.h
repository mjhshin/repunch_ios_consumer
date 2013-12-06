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
