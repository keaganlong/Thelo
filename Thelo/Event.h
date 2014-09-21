//
//  Event.h
//  Thelo
//
//  Created by Wayne Lu on 9/20/14.
//  Copyright (c) 2014 Alex Stelea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Event : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *eventDescription;
@property (nonatomic) CLLocationCoordinate2D coordinates;
@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) NSDate *endTime;
@property (strong, nonatomic) NSArray *comments;
@property (strong, nonatomic) NSString *eventID;
@property (strong, nonatomic) NSNumber *goingCount;

@end
