//
//  Channel.m
//  Thelo
//
//  Created by Wayne Lu on 9/20/14.
//  Copyright (c) 2014 Alex Stelea. All rights reserved.
//

#import "Channel.h"

@implementation Channel

@synthesize notificationRadius = _notificationRadius;
- (void)setNotificationRadius:(NSInteger)notificationRadius {
    [DefaultsManager setNotificationRadius:notificationRadius forChannel:self];
}

- (NSInteger)notificationRadius {
    return [DefaultsManager notificationRadiusForChannel:self];
}

@end
