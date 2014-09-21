//
//  APIHandler.m
//  Thelo
//
//  Created by Wayne Lu on 9/19/14.
//  Copyright (c) 2014 Alex Stelea. All rights reserved.
//

#import "APIHandler.h"
#import <AFNetworking/AFNetworking.h>
#import "Channel.h"
#import "Event.h"

#define BASE_API_URL @"http://vast-badlands-7635.herokuapp.com"
#define GET_CHANNELS_URL @"/channel/getAll"
#define CREATE_CHANNEL_URL @"/channel/addOne"
#define GET_EVENTS_URL @"/event/getAllEventsWithinRange"
#define CREATE_EVENT_URL @"/event/addOne"

@interface APIHandler ()
@property (strong, nonatomic) APIHandler *instance;
@end

@implementation APIHandler
#pragma mark - Instance
- (void)loginWithSuccessHandler:(void (^)())success failureHandler:(void(^)(NSError *))failure {
    success();
}

- (void)getChannelsWithSuccessHandler:(void (^)(NSArray *))success failureHandler:(void(^)(NSError *))failure {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASE_API_URL, GET_CHANNELS_URL]];
    NSURLRequest *request = [self _createGETRequestWithURL:url andParameters:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"GET response %@ %@", responseObject, [[request URL] absoluteString]);
        [self _onMainQueue:^{
            if (success) {
                NSDictionary *responseDict = (NSDictionary *)responseObject;
                NSMutableArray *channels = [[NSMutableArray alloc] init];
                for (NSDictionary *channel in responseDict[@"channels"]) {
                    if (channel[@"name"]) {
                        Channel *newChannel = [Channel new];
                        newChannel.name = channel[@"name"];
                        [channels addObject:newChannel];
                    }
                }
                success(channels);
            }
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"GET failed %@ %@", error.localizedDescription, [[request URL] absoluteString]);
        [self _onMainQueue:^{
            if (failure) {
                failure(error);
            }
        }];
    }];
    [operation start];
}

- (void)getEventsForChannel:(Channel *)channel withSuccessHandler:(void (^)(NSArray *))success failureHandler:(void(^)(NSError *))failure {
    CLLocation *location = [LocationManager currentLocation];
    CLLocationDegrees lat = location.coordinate.latitude;
    CLLocationDegrees lng = location.coordinate.longitude;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASE_API_URL, GET_EVENTS_URL]];
    NSDictionary *dictionary = @{@"channelName":channel.name,
                                 @"lat":[NSNumber numberWithDouble:lat],
                                 @"lng":[NSNumber numberWithDouble:lng],
                                 @"range":[NSNumber numberWithInt:10000]};
    NSURLRequest *request = [self _createPOSTRequestWithURL:url andDictionary:dictionary];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"POST response %@ %@", responseObject, [url absoluteString]);
        [self _onMainQueue:^{
            if (success) {
                NSDictionary *responseDict = (NSDictionary *)responseObject;
                NSMutableArray *events = [NSMutableArray new];
                for (NSDictionary *eventData in responseDict[@"events"]) {
                    Event *event = [Event new];
                    event.title = eventData[@"title"];
                    event.eventDescription = eventData[@"description"];
                    event.coordinates = CLLocationCoordinate2DMake([eventData[@"lat"] doubleValue], [eventData[@"lng"] doubleValue]);
                    event.startTime = [NSDate dateWithTimeIntervalSince1970:[eventData[@"startDate"] doubleValue]];
                    event.endTime = [NSDate dateWithTimeIntervalSince1970:[eventData[@"endDate"] doubleValue]];
                    event.comments = eventData[@"comments"];
                    [events addObject:event];
                }
                Event *event = [Event new];
                event.title = @"Test event";
                event.eventDescription = @"Yo, we hackin n shit";
                event.coordinates = CLLocationCoordinate2DMake(33, -84);
                event.startTime = [NSDate dateWithTimeIntervalSinceNow:-3000];
                event.endTime = [NSDate dateWithTimeIntervalSinceNow:5000];
                event.comments = [NSArray new];
                [events addObject:event];
                success(events);
            }
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"POST failed %@ %@", error.localizedDescription, [url absoluteString]);
        [self _onMainQueue:^{
            if (failure) {
                failure(error);
            }
        }];
    }];
    [operation start];
}

- (void)createEvent:(Event *)event inChannel:(Channel *)channel withSuccessHandler:(void (^)())success failureHandler:(void (^)(NSError *))failure {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASE_API_URL, CREATE_EVENT_URL]];
    CLLocationCoordinate2D coordinates = event.coordinates;
    CLLocationDegrees lat = coordinates.latitude;
    CLLocationDegrees lng = coordinates.longitude;
    NSDictionary *dictionary = @{@"channelName":channel.name,
                                 @"lat":[NSNumber numberWithDouble:lat],
                                 @"lng":[NSNumber numberWithDouble:lng],
                                 @"startDate":[NSNumber numberWithDouble:[event.startTime timeIntervalSince1970]],
                                 @"endDate":[NSNumber numberWithDouble:[event.endTime timeIntervalSince1970]],
                                 @"title":event.title,
                                 @"description":event.eventDescription};
    NSURLRequest *request = [self _createPOSTRequestWithURL:url andDictionary:dictionary];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"POST response %@ %@", responseObject, [url absoluteString]);
        [self _onMainQueue:^{
            if (success) {
                success();
            }
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"POST failed %@ %@", error.localizedDescription, [url absoluteString]);
        [self _onMainQueue:^{
            if (failure) {
                failure(error);
            }
        }];
    }];
    [operation start];
}

#pragma mark - Static
+ (void)loginWithSuccessHandler:(void (^)())success failureHandler:(void(^)(NSError *))failure {
    [[self instance] loginWithSuccessHandler:success failureHandler:failure];
}

+ (void)getChannelsWithSuccessHandler:(void (^)(NSArray *))success failureHandler:(void(^)(NSError *))failure {
    [[self instance] getChannelsWithSuccessHandler:success failureHandler:failure];
}
   
+ (void)getEventsForChannel:(Channel *)channel withSuccessHandler:(void (^)(NSArray *))success failureHandler:(void(^)(NSError *))failure {
    [[self instance] getEventsForChannel:channel withSuccessHandler:success failureHandler:failure];
}

+ (void)createEvent:(Event *)event inChannel:(Channel *)channel withSuccessHandler:(void (^)())success failureHandler:(void (^)(NSError *))failure {
    [[self instance] createEvent:event inChannel:channel withSuccessHandler:success failureHandler:failure];
}

#pragma mark - Private methods
- (NSURLRequest *)_createPOSTRequestWithURL:(NSURL *)url andDictionary:(NSDictionary *)dictionary {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString *dataLength = [NSString stringWithFormat:@"%li", [data length]];
    
    [request setHTTPBody:data];
    [request setValue:dataLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    return request;
}

- (NSURLRequest *)_createGETRequestWithURL:(NSURL *)url andParameters:(NSDictionary *)dictionary {
    if (dictionary) {
        NSMutableArray *kvPairs = [NSMutableArray new];
        for (NSString *key in dictionary) {
            [kvPairs addObject:[NSString stringWithFormat:@"%@=%@", key, dictionary[key]]];
        }
        NSString *valueString = [kvPairs componentsJoinedByString:@"&"];
        NSURL *valueURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@&%@", [url absoluteString], valueString]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:valueURL];
        [request setHTTPMethod:@"GET"];
        return request;
    } else {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"GET"];
        return request;
    }
}

- (void)_onMainQueue:(void (^)())handler {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (handler) {
            handler();
        }
    });
}

#pragma mark - Singleton
+ (APIHandler *)instance {
    static APIHandler *instance = nil;
    @synchronized(self) {
        if (instance == nil)
            instance = [[self alloc] init];
    }
    return instance;
}
@end
