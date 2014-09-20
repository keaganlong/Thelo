//
//  LocationManager.h
//  Thelo
//
//  Created by Wayne Lu on 9/20/14.
//  Copyright (c) 2014 Alex Stelea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject

+ (void)registerRegionAtLatitude:(double)latitude longitude:(double)longitude withRadius:(double)rad andIdentifier:(NSString *)identifier;
+ (void)requestPermissions;
+ (CLLocation *)currentLocation;

@end
