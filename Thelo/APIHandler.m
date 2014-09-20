//
//  APIHandler.m
//  Thelo
//
//  Created by Wayne Lu on 9/19/14.
//  Copyright (c) 2014 Alex Stelea. All rights reserved.
//

#import "APIHandler.h"
#import <AFNetworking/AFNetworking.h>

#define BASE_API_URL @"http://localhost:3000"
#define CHANNEL_URL @"/channel"
#define EVENTS_URL @"/events"

@interface APIHandler ()
@property (strong, nonatomic) APIHandler *instance;
@end

@implementation APIHandler
#pragma mark - Instance
- (void)loginWithSuccessHandler:(void (^)())success failureHandler:(void(^)(NSError *))failure {
    success();
}

- (void)getChannelsWithSuccessHandler:(void (^)(NSArray *))success failureHandler:(void(^)(NSError *))failure {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASE_API_URL, CHANNEL_URL]];
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
                    [channels addObject:channel[@"name"]];
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

- (void)getEventsWithSuccessHandler:(void (^)(NSArray *))success failureHandler:(void(^)(NSError *))failure {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASE_API_URL, CHANNEL_URL]];
    NSURLRequest *request = [self _createGETRequestWithURL:url andParameters:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"GET response %@ %@", responseObject, [url absoluteString]);
        [self _onMainQueue:^{
            if (success) {
                NSDictionary *responseDict = (NSDictionary *)responseObject;
                NSMutableArray *channels = [[NSMutableArray alloc] init];
                for (NSDictionary *channel in responseDict[@"channels"]) {
                    [channels addObject:channel[@"name"]];
                }
                success(channels);
            }
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"GET failed %@ %@", error.localizedDescription, [url absoluteString]);
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
