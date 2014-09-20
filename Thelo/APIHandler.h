//
//  APIHandler.h
//  Thelo
//
//  Created by Wayne Lu on 9/19/14.
//  Copyright (c) 2014 Alex Stelea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIHandler : NSObject

+ (void)loginWithSuccessHandler:(void (^)())success failureHandler:(void(^)(NSError *))failure;

@end
