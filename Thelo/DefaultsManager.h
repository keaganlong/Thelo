//
//  DefaultsManager.h
//  Thelo
//
//  Created by Wayne Lu on 9/19/14.
//  Copyright (c) 2014 Alex Stelea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Channel.h"
#import "Event.h"

#define DEVICE_ID [[[UIDevice currentDevice] identifierForVendor] UUIDString]

@interface DefaultsManager : NSObject

+ (NSInteger)notificationRadiusForChannel:(Channel *)channel;
+ (void)setNotificationRadius:(NSInteger)radius forChannel:(Channel *)channel;
+ (void)setIntentToAttendEvent:(Event *)event;
+ (BOOL)intentToAttendEvent:(Event *)event;
+ (void)setAttendanceOfEvent:(Event *)event;
+ (BOOL)attendanceOfEvent:(Event *)event;

@end
