//
//  NSDate+PrettyDate.h
//  Repunch
//
//  Created by Emil Landron on 9/7/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Additions)

- (BOOL)isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate;

- (NSString*)prettyDate;

- (BOOL)isGreaterThan:(NSDate*)date;

+ (NSString *)formattedDateFromStoreHours:(NSString *)time;

@end
