//
//  DefaultsManager.m
//  Thelo
//
//  Created by Wayne Lu on 9/19/14.
//  Copyright (c) 2014 Alex Stelea. All rights reserved.
//

#import "DefaultsManager.h"

@implementation DefaultsManager

+ (NSString *)username {
    return [[NSUserDefaults standardUserDefaults] stringForKey:USERNAME];
}

+ (NSString *)password {
    return [[NSUserDefaults standardUserDefaults] stringForKey:PASSWORD];
}

+ (void)setUsername:(NSString *)username {
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:USERNAME];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setPassword:(NSString *)password {
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:PASSWORD];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
