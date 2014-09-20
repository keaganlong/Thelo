//
//  APIHandler.m
//  Thelo
//
//  Created by Wayne Lu on 9/19/14.
//  Copyright (c) 2014 Alex Stelea. All rights reserved.
//

#import "APIHandler.h"
#import <AFNetworking/AFNetworking.h>

@interface APIHandler ()
@property (strong, nonatomic) APIHandler *instance;
@end

@implementation APIHandler
#pragma mark - Instance
- (void)loginWithSuccessHandler:(void (^)())success failureHandler:(void(^)(NSError *))failure {
    success();
}

#pragma mark - Static
+ (void)loginWithSuccessHandler:(void (^)())success failureHandler:(void(^)(NSError *))failure {
    [[self instance] loginWithSuccessHandler:success failureHandler:failure];
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
