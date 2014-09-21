//
//  NotificationManager.m
//  Thelo
//
//  Created by Wayne Lu on 9/20/14.
//  Copyright (c) 2014 Alex Stelea. All rights reserved.
//

#import "NotificationManager.h"

@implementation NotificationManager

+ (void)fireActionableLocalNotificationWithMessage:(NSString *)message forEvent:(Event *)event {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [[NSDate alloc] init];
    notification.alertBody = message;
    notification.category = @"intentCategory";
    notification.userInfo = @{@"event":event.eventID};
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

+ (void)fireLocalNotificationWithMessage:(NSString *)message forEvent:(Event *)event {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [[NSDate alloc] init];
    notification.alertBody = message;
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

@end
