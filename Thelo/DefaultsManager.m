//
//  DefaultsManager.m
//  Thelo
//
//  Created by Wayne Lu on 9/19/14.
//  Copyright (c) 2014 Alex Stelea. All rights reserved.
//

#import "DefaultsManager.h"

@implementation DefaultsManager

+ (NSInteger)notificationRadiusForChannel:(Channel *)channel {
    double radius = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"channel_%@", channel.channelID]];
    if (radius == 0) {
        radius = 100;
        [DefaultsManager setNotificationRadius:100.0 forChannel:channel];
    }
    return radius;
}

+ (void)setNotificationRadius:(NSInteger)radius forChannel:(Channel *)channel {
    [[NSUserDefaults standardUserDefaults] setInteger:radius forKey:[NSString stringWithFormat:@"channel_%@", channel.channelID]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setIntentToAttendEvent:(Event *)event {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"event_intents"];
    NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    newDict[event.eventID] = [NSNumber numberWithBool:YES];
    [[NSUserDefaults standardUserDefaults] setObject:newDict forKey:@"event_intents"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)intentToAttendEvent:(Event *)event {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"event_intents"];
    return ([dict objectForKey:event.eventID] != nil);
}

+ (void)setAttendanceOfEvent:(Event *)event {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"event_attend"];
    NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    newDict[event.eventID] = [NSNumber numberWithBool:YES];
    [[NSUserDefaults standardUserDefaults] setObject:newDict forKey:@"event_attend"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)attendanceOfEvent:(Event *)event {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"event_attend"];
    return ([dict objectForKey:event.eventID] != nil);
}

+ (void)notifiedOfEvent:(Event *)event {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"event_notified"];
    NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    newDict[event.eventID] = [NSNumber numberWithBool:YES];
    [[NSUserDefaults standardUserDefaults] setObject:newDict forKey:@"event_notified"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)hasNotifiedOfEvent:(Event *)event {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"event_notified"];
    return ([dict objectForKey:event.eventID] != nil);
}

+ (void)clearNotificationOfEvent:(Event *)event {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"event_notified"];
    NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    [newDict removeObjectForKey:event.eventID];
    [[NSUserDefaults standardUserDefaults] setObject:newDict forKey:@"event_notified"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
