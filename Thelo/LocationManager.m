//
//  LocationManager.m
//  Thelo
//
//  Created by Wayne Lu on 9/20/14.
//  Copyright (c) 2014 Alex Stelea. All rights reserved.
//

#import "LocationManager.h"
#import <CoreLocation/CoreLocation.h>

@interface LocationManager () <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *manager;
@property (strong, nonatomic) LocationManager *instance;
@end

@implementation LocationManager

+ (void)registerRegionAtLatitude:(double)latitude longitude:(double)longitude withRadius:(double)rad andIdentifier:(NSString *)identifier {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    CLLocationDistance radius = rad;
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:coordinate radius:radius identifier:identifier];
    region.notifyOnExit = NO;
    [[LocationManager manager] startMonitoringForRegion:region];
    for (CLCircularRegion *monReg in [[LocationManager manager] monitoredRegions]) {
        NSLog(@"Monitoring: (%f, %f) id: %@", monReg.center.latitude, monReg.center.longitude, monReg.identifier);
    }
}

+ (void)requestPermissions {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [[LocationManager manager] requestAlwaysAuthorization];
    }
}

+ (CLLocationManager *)manager {
    return [[LocationManager instance] manager];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    CLCircularRegion *circRegion = (CLCircularRegion *)region;
    [NotificationManager fireLocalNotificationWithMessage:[NSString stringWithFormat:@"Entered region: (%f,%f)", circRegion.center.latitude, circRegion.center.longitude]];
}

#pragma mark - Singleton
+ (LocationManager *)instance {
    static LocationManager *instance = nil;
    @synchronized(self) {
        if (instance == nil) {
            instance = [[self alloc] init];
            instance.manager = [[CLLocationManager alloc] init];
            instance.manager.delegate = instance;
            [instance.manager startUpdatingLocation];
            instance.manager.pausesLocationUpdatesAutomatically = NO;
        }
    }
    return instance;
}
@end