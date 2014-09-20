//
//  DefaultsManager.h
//  Thelo
//
//  Created by Wayne Lu on 9/19/14.
//  Copyright (c) 2014 Alex Stelea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DefaultsManager : NSObject

+ (NSString *)username;
+ (NSString *)password;

+ (void)setUsername:(NSString *)username;
+ (void)setPassword:(NSString *)password;

@end
