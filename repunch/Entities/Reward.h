//
//  Reward.h
//  Repunch
//
//  Created by Gwendolyn Weston on 6/17/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Reward : NSManagedObject

@property (nonatomic, retain) NSString * punches;
@property (nonatomic, retain) NSNumber * reward_description;
@property (nonatomic, retain) NSString * reward_name;

@end
