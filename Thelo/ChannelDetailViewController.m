//
//  ChannelDetailViewController.m
//  Thelo
//
//  Created by Alex Stelea on 9/20/14.
//  Copyright (c) 2014 Alex Stelea. All rights reserved.
//

#import "ChannelDetailViewController.h"
#import <MapKit/MapKit.h>

@interface ChannelDetailViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet MKRoute *walkingRoute;

@property (nonatomic) IBOutlet MKMapItem *mapItem;
@end

@implementation ChannelDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = @"Free food";
    self.timeLabel.text = @"2 hours ago";

    
    self.mapView.delegate = self;
    [self getWalkingDirections];

    
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
    
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(33.776729599999996, -84.396323) addressDictionary:nil];
    _mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    [_mapItem setName:@"The location name"];
    [_mapItem openInMapsWithLaunchOptions:nil];
}

- (void) getWalkingDirections {
    MKDirectionsRequest *walkingRouteRequest = [[MKDirectionsRequest alloc] init];
    walkingRouteRequest.transportType = MKDirectionsTransportTypeWalking;
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:[[LocationManager currentLocation] coordinate] addressDictionary:nil];
    [walkingRouteRequest setSource:[[MKMapItem alloc] initWithPlacemark:placemark]];
    placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(33.776729599999996, -84.407323) addressDictionary:nil];
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:CLLocationCoordinate2DMake(33.776729599999996, -84.407323)];
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



@end
