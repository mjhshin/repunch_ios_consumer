//
//  RPConstants.h
//  RepunchConsumer
//
//  Created by Michael Shin on 10/25/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#ifndef RepunchConsumer_RPConstants_h
#define RepunchConsumer_RPConstants_h

#define IS_NIL(x) ([x isKindOfClass:[NSNull class]] || x == nil)

typedef void(^AuthenticationManagerHandler)(NSInteger errorCode);

#endif
