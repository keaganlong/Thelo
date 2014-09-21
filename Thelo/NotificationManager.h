//
//  NotificationManager.h
//  Thelo
//
//  Created by Wayne Lu on 9/20/14.
//  Copyright (c) 2014 Alex Stelea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationManager : NSObject

+ (void)fireActionableLocalNotificationWithMessage:(NSString *)message forEvent:(Event *)event;
+ (void)fireLocalNotificationWithMessage:(NSString *)message forEvent:(Event *)event;

@end
