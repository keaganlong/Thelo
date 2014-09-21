//
//  ChannelDetailViewController.m
//  Thelo
//
//  Created by Alex Stelea on 9/20/14.
//  Copyright (c) 2014 Alex Stelea. All rights reserved.
//

#import "EventViewController.h"
#import <MapKit/MapKit.h>

@interface EventViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet MKRoute *walkingRoute;

@property (nonatomic) IBOutlet MKMapItem *mapItem;
@end


@implementation EventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = self.event.title;
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.doesRelativeDateFormatting = YES;
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setLocale:[NSLocale currentLocale]];
    self.timeLabel.text = [self _dateDiff:self.event.startTime];

    self.mapView.delegate = self;
    [self getWalkingDirections];

    
}

- (void)setEvent:(Event *)event {
    _event = event;
    self.title = event.title;
    self.titleLabel.text = event.title;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    
    MKPolyline *polyline = (MKPolyline *) overlay;
    MKPolylineView *polyLineView = [[MKPolylineView alloc] initWithPolyline:polyline];
    polyLineView.fillColor = [UIColor blueColor];
    polyLineView.strokeColor = [UIColor blueColor];
    polyLineView.lineWidth = 7;
    return polyLineView;
}

- (IBAction)openInMaps:(id)sender {
    
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.event.coordinates addressDictionary:nil];
    _mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    [_mapItem setName:@"The location name"];
    [_mapItem openInMapsWithLaunchOptions:nil];
}

- (void) getWalkingDirections {
    MKDirectionsRequest *walkingRouteRequest = [[MKDirectionsRequest alloc] init];
    walkingRouteRequest.transportType = MKDirectionsTransportTypeWalking;
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:[[LocationManager currentLocation] coordinate] addressDictionary:nil];
    [walkingRouteRequest setSource:[[MKMapItem alloc] initWithPlacemark:placemark]];
    placemark = [[MKPlacemark alloc] initWithCoordinate:self.event.coordinates addressDictionary:nil];
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:self.event.coordinates];
    [walkingRouteRequest setDestination :[[MKMapItem alloc] initWithPlacemark:placemark]];
    
    MKDirections *walkingRouteDirections = [[MKDirections alloc] initWithRequest:walkingRouteRequest];
    [walkingRouteDirections calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * walkingRouteResponse, NSError *walkingRouteError) {
        if (walkingRouteError) {
            NSLog(@"alex");
        } else {
            // The code doesn't request alternate routes, so add the single calculated route to
            // a previously declared MKRoute property called walkingRoute.
//            NSLog(@"%lu", (unsigned long)[walkingRouteResponse.routes count]);
            
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self.mapView addAnnotation:annotation];

                for (MKRoute *route in walkingRouteResponse.routes)
                {

                    for (MKRouteStep *step in route.steps)
                    {
                        NSLog(@"%@", step);
                        [_mapView insertOverlay:step.polyline aboveOverlay:MKOverlayLevelAboveRoads];
                    }
                }
            });

            
            
        }
    }];
}
- (void)displayRegionCenteredOnMapItem:(MKMapItem*)from {
    CLLocation* fromLocation = from.placemark.location;
    
    // Create a region centered on the starting point with a 10km span
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(fromLocation.coordinate, 10000, 10000);
    
    // Open the item in Maps, specifying the map region to display.
    [MKMapItem openMapsWithItems:[NSArray arrayWithObject:from]
                   launchOptions:[NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSValue valueWithMKCoordinate:region.center], MKLaunchOptionsMapCenterKey,
                                  [NSValue valueWithMKCoordinateSpan:region.span], MKLaunchOptionsMapSpanKey, nil]];
}

#pragma mark - Private methods
- (NSString *)_dateDiff:(NSDate *)date {
    NSDate *todayDate = [NSDate date];
    double ti = [date timeIntervalSinceDate:todayDate];
    ti = ti * -1;
    if(ti < 1) {
        return @"never";
    } else 	if (ti < 60) {
        return @"less than a minute ago";
    } else if (ti < 3600) {
        int diff = round(ti / 60);
        return [NSString stringWithFormat:@"%d minutes ago", diff];
    } else if (ti < 86400) {
        int diff = round(ti / 60 / 60);
        return[NSString stringWithFormat:@"%d hours ago", diff];
    } else if (ti < 2629743) {
        int diff = round(ti / 60 / 60 / 24);
        return[NSString stringWithFormat:@"%d days ago", diff];
    } else {
        return @"never";
    }	
}

@end
