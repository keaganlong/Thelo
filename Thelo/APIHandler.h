//
//  APIHandler.h
//  Thelo
//
//  Created by Wayne Lu on 9/19/14.
//  Copyright (c) 2014 Alex Stelea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Channel.h"
#import "Event.h"

@interface APIHandler : NSObject

+ (void)loginWithSuccessHandler:(void (^)())success failureHandler:(void(^)(NSError *))failure;
+ (void)getSubscribedChannelsWithSuccessHandler:(void (^)(NSArray *))success failureHandler:(void (^)(NSError *))failure;
+ (void)subscribeToChannel:(Channel *)channel withSuccessHandler:(void (^)())success failureHandler:(void(^)(NSError *))failure;
+ (void)unsubscribeFromChannel:(Channel *)channel withSuccessHandler:(void (^)())success failureHandler:(void(^)(NSError *))failure;
+ (void)getChannelsWithSuccessHandler:(void (^)(NSArray *))success failureHandler:(void(^)(NSError *))failure;
+ (void)getEventsForChannel:(Channel *)channel withSuccessHandler:(void (^)(NSArray *))success failureHandler:(void(^)(NSError *))failure;
+ (void)createEvent:(Event *)event inChannel:(Channel *)channel withSuccessHandler:(void (^)(BOOL, NSString *))success failureHandler:(void (^)(NSError *))failure;
+ (void)setIntentToAttendEvent:(Event *)event withSuccessHandler:(void (^)())success failureHandler:(void (^)(NSError *))failure;
+ (void)setAttendanceOfEvent:(Event *)event withSuccessHandler:(void (^)())success failureHandler:(void (^)(NSError *))failure;
+ (void)getIntentToAttendCountForEvent:(Event *)event withSuccessHandler:(void (^)(NSNumber *))success failureHandler:(void (^)(NSError *))failure;
+ (void)getAttendCountForEvent:(Event *)event withSuccessHandler:(void (^)(NSNumber *))success failureHandler:(void (^)(NSError *))failure;


@end
