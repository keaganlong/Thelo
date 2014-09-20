//
//  Channel.h
//  Thelo
//
//  Created by Wayne Lu on 9/20/14.
//  Copyright (c) 2014 Alex Stelea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Channel : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray *events;
@property (nonatomic) NSInteger *notificationRadius;

@end
