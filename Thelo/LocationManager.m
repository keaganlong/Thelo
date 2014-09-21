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
@property (strong, atomic) NSMutableArray *events;
@property (strong, nonatomic) CLLocation *lastLocation;
@end

@implementation LocationManager

+ (void)registerRegionAtLatitude:(double)latitude longitude:(double)longitude withRadius:(double)rad andIdentifier:(NSString *)identifier {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    CLLocationDistance radius = rad;
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:coordinate radius:radius identifier:identifier];
    region.notifyOnExit = NO;
    [[LocationManager manager] startMonitoringForRegion:region];
    //[[LocationManager manager] requestStateForRegion:region];
    for (CLCircularRegion *monReg in [[LocationManager manager] monitoredRegions]) {
        //NSLog(@"Monitoring id:%@ at:(%f, %f) radius:%f", monReg.identifier, monReg.center.latitude, monReg.center.longitude, monReg.radius);
    }
}

+ (void)clearRegisterRegions {
    for (CLCircularRegion *monReg in [[LocationManager manager] monitoredRegions]) {
        [[LocationManager manager] stopMonitoringForRegion:monReg];
    }
}

+ (CLLocation *)currentLocation {
    return [[LocationManager manager] location];
}

+ (void)requestPermissions {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [[LocationManager manager] requestAlwaysAuthorization];
    } else if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Permission needed"
                                            message:@"Thelo needs location services to function properly!"
                                     preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Got it." style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
        }]];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    }
}

+ (void)forceMonitoredRegionsUpdate {
    [[LocationManager instance] _populateMonitoredRegions];
}

+ (CLLocationManager *)manager {
    return [[LocationManager instance] manager];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    CLCircularRegion *circRegion = (CLCircularRegion *)region;
    NSArray *components = [circRegion.identifier componentsSeparatedByString:@"#0#"];
    NSString *eventName = components[0];
    NSString *eventID = components[1];
    Event *firingEvent;
    for (Event *event in self.events) {
        if ([event.eventID isEqualToString:eventID]) {
            firingEvent = event;
            break;
        }
    }
    if (firingEvent && !firingEvent.firedNotification) {
        if ([DefaultsManager intentToAttendEvent:firingEvent]) {
            if (![DefaultsManager attendanceOfEvent:firingEvent]) {
                [NotificationManager fireLocalNotificationWithMessage:[NSString stringWithFormat:@"Arrived at %@", eventName] forEvent:firingEvent];
                [APIHandler setAttendanceOfEvent:firingEvent withSuccessHandler:nil failureHandler:nil];
            }
        } else {
            [NotificationManager fireActionableLocalNotificationWithMessage:[NSString stringWithFormat:@"%@ within %1.0fm", eventName, circRegion.radius] forEvent:firingEvent];
            firingEvent.firedNotification = YES;
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    if (state == CLRegionStateInside) {
        CLCircularRegion *circRegion = (CLCircularRegion *)region;
        NSArray *components = [circRegion.identifier componentsSeparatedByString:@"#0#"];
        NSString *eventName = components[0];
        NSString *eventID = components[1];
        Event *firingEvent;
        for (Event *event in self.events) {
            if ([event.eventID isEqualToString:eventID]) {
                firingEvent = event;
                break;
            }
        }
        if (firingEvent) {
            if ([DefaultsManager intentToAttendEvent:firingEvent]) {
                if (![DefaultsManager attendanceOfEvent:firingEvent]) {
                    [NotificationManager fireLocalNotificationWithMessage:[NSString stringWithFormat:@"Arrived at %@", eventName] forEvent:firingEvent];
                    [APIHandler setAttendanceOfEvent:firingEvent withSuccessHandler:nil failureHandler:nil];
                }
            } else {
                [NotificationManager fireActionableLocalNotificationWithMessage:[NSString stringWithFormat:@"%@ within %1.0fm", eventName, circRegion.radius] forEvent:firingEvent];
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = [locations lastObject];
    //NSLog(@"currently at (%f, %f)", newLocation.coordinate.latitude, newLocation.coordinate.latitude);
    for (CLCircularRegion *region in [[LocationManager manager] monitoredRegions]) {
        CLLocation *regionLoc = [[CLLocation alloc] initWithLatitude:region.center.latitude longitude:region.center.longitude];
        //NSLog(@"monitoring (%f, %f), %f away", region.center.latitude, region.center.longitude, [newLocation distanceFromLocation:regionLoc]);
        //[[LocationManager manager] requestStateForRegion:region];
    }
    if (self.lastLocation) {
        if ([self.lastLocation distanceFromLocation:newLocation] > 1000) {
            [self _populateMonitoredRegions];
            self.lastLocation = newLocation;
        }
    } else {
        [self _populateMonitoredRegions];
        self.lastLocation = newLocation;
    }
}

#pragma mark - Private methods
- (void)_populateMonitoredRegions {
    [APIHandler getSubscribedChannelsWithSuccessHandler:^(NSArray *channels) {
        for (Channel *channel in channels) {
            [APIHandler getEventsForChannel:channel withSuccessHandler:^(NSArray *events) {
                for (Event *event in events) {
                    if ([self.events count] < 15) {
                        [self.events addObject:event];
                    }
                    else {
                        Event *removalTarget;
                        for (Event *oldEvent in self.events) {
                            CLLocation *newLocation = [[CLLocation alloc] initWithCoordinate:event.coordinates altitude:1 horizontalAccuracy:1 verticalAccuracy:-1 timestamp:nil];
                            CLLocation *oldLocation = [[CLLocation alloc] initWithCoordinate:oldEvent.coordinates altitude:1 horizontalAccuracy:1 verticalAccuracy:-1 timestamp:nil];
                            CLLocation *currentLocation = [LocationManager currentLocation];
                            if ([currentLocation distanceFromLocation:newLocation] < [currentLocation distanceFromLocation:oldLocation]) {
                                removalTarget = oldEvent;
                                break;
                            }
                        }
                        if (removalTarget) {
                            [self.events removeObject:removalTarget];
                            [self.events addObject:event];
                        }
                    }
                }
                [LocationManager clearRegisterRegions];
                for (Event *event in self.events) {
                    double radius = [DefaultsManager intentToAttendEvent:event] ? 50.0 : channel.notificationRadius;
                    [LocationManager registerRegionAtLatitude:event.coordinates.latitude
                                                    longitude:event.coordinates.longitude
                                                   withRadius:radius
                                                andIdentifier:[NSString stringWithFormat:@"%@#0#%@", event.title, event.eventID]];
                }
            } failureHandler:nil];
        }
    } failureHandler:nil];
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
            [instance.manager startMonitoringSignificantLocationChanges];
            instance.manager.pausesLocationUpdatesAutomatically = NO;
            instance.events = [NSMutableArray new];
        }
    }
    return instance;
}
@end
