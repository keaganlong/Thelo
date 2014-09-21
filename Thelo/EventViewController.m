//
//  ChannelDetailViewController.m
//  Thelo
//
//  Created by Alex Stelea on 9/20/14.
//  Copyright (c) 2014 Alex Stelea. All rights reserved.
//

#import "EventViewController.h"
#import <MapKit/MapKit.h>
#import "FUISwitch.h"
#import "UIColor+FlatUI.h"
#import "UIFont+FlatUI.h"

@interface EventViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet MKRoute *walkingRoute;
@property (nonatomic) MKPointAnnotation *annotation;
@property (nonatomic) IBOutlet MKMapItem *mapItem;
@property (weak, nonatomic) IBOutlet UITextView *detailViewText;
@property (weak, nonatomic) IBOutlet FUISwitch *attendingSwitch;
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
    UIFont *myFont = [UIFont flatFontOfSize:36];
    self.titleLabel.font = myFont;
    self.timeLabel.text = [self _dateDiff:self.event.startTime];
    _attendingSwitch.onColor = [UIColor turquoiseColor];
    _attendingSwitch.offColor = [UIColor cloudsColor];
    _attendingSwitch.onLabel.text = @"Going";
    _attendingSwitch.offLabel.text = @"Not Going";
    _attendingSwitch.on = [DefaultsManager intentToAttendEvent:self.event];
    _attendingSwitch.enabled = !_attendingSwitch.on;

    _attendingSwitch.onBackgroundColor = [UIColor midnightBlueColor];
    _attendingSwitch.offBackgroundColor = [UIColor silverColor];
    _attendingSwitch.offLabel.font = [UIFont boldFlatFontOfSize:14];
    _attendingSwitch.onLabel.font = [UIFont boldFlatFontOfSize:14];

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

- (IBAction)goingStateChanged:(id)sender {
    FUISwitch *goingSwitch = (FUISwitch *)sender;
    if (goingSwitch.on) {
        _attendingSwitch.enabled = NO;
        [APIHandler setIntentToAttendEvent:self.event withSuccessHandler:nil failureHandler:nil];
    }
}

- (IBAction)shareButtonPressed:(id)sender {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setDateFormat:@"hh:mma"];
    NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%f,%f",
                           self.event.coordinates.latitude,
                           self.event.coordinates.longitude];
    NSString *shareMessage = [NSString stringWithFormat:@"Yo! There's %@ at (%f,%f) between %@ and %@! Be there, or b^2. %@ #BAWK",
                              self.event.title,
                              self.event.coordinates.latitude,
                              self.event.coordinates.longitude,
                              [formatter stringFromDate:self.event.startTime],
                              [formatter stringFromDate:self.event.endTime],
                              urlString];
    
    UIActivityViewController *shareView = [[UIActivityViewController alloc] initWithActivityItems:@[shareMessage] applicationActivities:nil];
    [self presentViewController:shareView animated:YES completion:nil];
}

- (void) getWalkingDirections {
    MKDirectionsRequest *walkingRouteRequest = [[MKDirectionsRequest alloc] init];
    walkingRouteRequest.transportType = MKDirectionsTransportTypeWalking;
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:[[LocationManager currentLocation] coordinate] addressDictionary:nil];
    [walkingRouteRequest setSource:[[MKMapItem alloc] initWithPlacemark:placemark]];
    placemark = [[MKPlacemark alloc] initWithCoordinate:self.event.coordinates addressDictionary:nil];
    self.annotation = [[MKPointAnnotation alloc] init];
    [self.annotation setCoordinate:self.event.coordinates];
    [self.annotation setTitle:self.event.title];
    [self.mapView addAnnotation:self.annotation];
    [walkingRouteRequest setDestination :[[MKMapItem alloc] initWithPlacemark:placemark]];
    
    MKDirections *walkingRouteDirections = [[MKDirections alloc] initWithRequest:walkingRouteRequest];
    [walkingRouteDirections calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * walkingRouteResponse, NSError *walkingRouteError) {
        if (walkingRouteError) {
            NSLog(@"There was a error returning the walking data");
        } else {
            // The code doesn't request alternate routes, so add the single calculated route to
            // a previously declared MKRoute property called walkingRoute.
            
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self.mapView addAnnotation:self.annotation];

                for (MKRoute *route in walkingRouteResponse.routes)
                {

                    for (MKRouteStep *step in route.steps)
                    {
                        NSLog(@"%@", step);
                        [_mapView insertOverlay:step.polyline aboveOverlay:MKOverlayLevelAboveRoads];
                    }
                }
            });

            MKCoordinateSpan locationSpan;
            
            float maxLat = MAX(self.event.coordinates.latitude, [[LocationManager currentLocation] coordinate].latitude);
            float maxLong = MAX(self.event.coordinates.longitude, [[LocationManager currentLocation] coordinate].longitude);
            float minLat = MIN(self.event.coordinates.latitude, [[LocationManager currentLocation] coordinate].latitude);
            float minLong = MIN(self.event.coordinates.longitude, [[LocationManager currentLocation] coordinate].longitude);
            
            locationSpan.latitudeDelta = (maxLat - minLat) * 2.0;
            locationSpan.longitudeDelta = (maxLong - minLong) * 2.0;
            CLLocationCoordinate2D center = CLLocationCoordinate2DMake((maxLat + minLat) * 0.5, (maxLong + minLong) * 0.5);

            [self.mapView setRegion:MKCoordinateRegionMake(center, locationSpan)];
                        
            self.detailViewText.text = self.event.eventDescription;

            
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
