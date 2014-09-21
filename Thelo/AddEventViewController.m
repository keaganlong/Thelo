//
//  AddEventViewController.m
//  Thelo
//
//  Created by Alex Stelea on 9/20/14.
//  Copyright (c) 2014 Alex Stelea. All rights reserved.
//

#import "AddEventViewController.h"
#import <MapKit/MapKit.h>
#import "DraggablePin.h"

@interface AddEventViewController () <UIPickerViewDataSource, UIPickerViewDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UIPickerView *channelPickerView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextField *addressField;
@property (strong, nonatomic)          NSArray *channelsArray;
@property (weak, nonatomic) IBOutlet UIButton *currentLocationButton;
@property (weak, nonatomic) IBOutlet UILabel *addressText;
@property (nonatomic) BOOL pinAdded;
@end



@implementation AddEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.channelPickerView.delegate = self;
    self.mapView.delegate = self;
    
//    [self.mapView setCenterCoordinate:[[LocationManager currentLocation] coordinate] animated:YES];
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    region.span = span;
    region.center = [[LocationManager currentLocation] coordinate];
    [self.mapView setRegion:region animated:YES];

    
    self.channelsArray  = [[NSArray alloc]         initWithObjects:@"Channel 1",@"Channel 2",@"Channel 3",@"Channel 4",@"Channel 5",@"Channel 6" , nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MKAnnotationView *) mapView: (MKMapView *) mapView viewForAnnotation: (id<MKAnnotation>) annotation {
    MKPinAnnotationView *pin = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier: @"myPin"];
    if (pin == nil) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"myPin"]; 
    } else {
        pin.annotation = annotation;
    }
    pin.animatesDrop = YES;
    pin.draggable = YES;
    
    return pin;
}


- (IBAction)findCurrentUserLocation:(id)sender {
    CLLocationCoordinate2D coords = [[LocationManager currentLocation] coordinate];
    DraggablePin *annotation = [[DraggablePin alloc]initWithCoordinate:coords];
    if (!self.pinAdded) {
        [self.mapView addAnnotation:annotation];
        [self.mapView setCenterCoordinate:coords animated:NO];

        self.pinAdded = YES;
    }
    else {
        [self.mapView removeAnnotations:[self.mapView annotations]];

        [annotation setCoordinate:coords];
        [self.mapView addAnnotation:annotation];
        [self.mapView setCenterCoordinate:coords animated:NO];

        
    }
    
}


- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)annotationView
didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState
{
    if (newState == MKAnnotationViewDragStateEnding)
    {
        CLLocationCoordinate2D droppedAt = annotationView.annotation.coordinate;
        NSLog(@"Pin dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);
        CLLocation *currentLocation = [[CLLocation alloc]
                                       initWithLatitude:droppedAt.latitude
                                       longitude:droppedAt.longitude];
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemark, NSError *error) {
            NSString *annTitle = @"Address unknown";
            
            //set the title if we got any placemarks...
            if (placemark.count > 0)
            {
                CLPlacemark *topResult = [placemark objectAtIndex:0];
                annTitle = [NSString stringWithFormat:@"%@", topResult.thoroughfare];
            }
            
            self.addressText.text = annTitle;
        }];

        
        
    }
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row   forComponent:(NSInteger)component
{
    
    return [self.channelsArray objectAtIndex:row];
    
}

- (IBAction)dismissModalViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
    
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    return 6;
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
