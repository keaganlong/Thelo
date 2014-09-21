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

@end
