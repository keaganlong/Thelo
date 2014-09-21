//
//  AddEventViewController.m
//  Thelo
//
//  Created by Alex Stelea on 9/20/14.
//  Copyright (c) 2014 Alex Stelea. All rights reserved.
//

#import "AddEventViewController.h"
#import <MapKit/MapKit.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import "DraggablePin.h"
#import "Channel.h"
#import "Event.h"

@interface AddEventViewController () <UIPickerViewDataSource, UIPickerViewDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UIPickerView *channelPickerView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextField *addressField;
@property (strong, nonatomic)          NSArray *channelsArray;
@property (weak, nonatomic) IBOutlet UIButton *currentLocationButton;
@property (weak, nonatomic) IBOutlet UILabel *addressText;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (nonatomic) BOOL pinAdded;
@property (strong, nonatomic) DraggablePin *pin;
@end



@implementation AddEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.channelPickerView.delegate = self;
    self.mapView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
    
//    [self.mapView setCenterCoordinate:[[LocationManager currentLocation] coordinate] animated:YES];
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    region.span = span;
    region.center = [[LocationManager currentLocation] coordinate];
    [self.mapView setRegion:region animated:YES];

    [APIHandler getChannelsWithSuccessHandler:^(NSArray *channels) {
        self.channelsArray = channels;
        [self.channelPickerView reloadAllComponents];
    } failureHandler:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.titleTextField) {
        [textField resignFirstResponder];
        [self.descriptionTextField becomeFirstResponder];
    } else if (textField == self.descriptionTextField) {
        [self addButtonPressed:nil];
    }
    return YES;
}

- (void)keyboardDidShow {
    CGPoint center = CGPointApplyAffineTransform(self.view.center, CGAffineTransformMakeTranslation(0, -60.0));
    self.view.center = center;
}

- (void)keyboardWillHide {
    CGPoint center = CGPointApplyAffineTransform(self.view.center, CGAffineTransformMakeTranslation(0, 60.0));
    self.view.center = center;
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
    self.pin = annotation;
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
    Channel *channel = [self.channelsArray objectAtIndex:row];
    return channel.name;
}

- (IBAction)addButtonPressed:(id)sender {
    if ([self _validateFields]) {
        LAContext *myContext = [[LAContext alloc] init];
        NSError *authError = nil;
        NSString *myLocalizedReasonString = @"Please verify before creating event.";
        
        if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
            [myContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                      localizedReason:myLocalizedReasonString
                                reply:^(BOOL success, NSError *error) {
                                    if (success) {
                                        Event *newEvent = [Event new];
                                        Channel *channel = [self.channelsArray objectAtIndex:[self.channelPickerView selectedRowInComponent:0]];
                                        newEvent.title = self.titleTextField.text;
                                        newEvent.eventDescription = self.descriptionTextField.text;
                                        newEvent.coordinates = self.pin.coordinate;
                                        newEvent.startTime = [NSDate date];
                                        newEvent.endTime = [NSDate dateWithTimeIntervalSinceNow:(3*60*60)];
                                        [APIHandler createEvent:newEvent inChannel:channel withSuccessHandler:^{
                                            [self dismissViewControllerAnimated:YES completion:nil];
                                        } failureHandler:^(NSError *error) {
                                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                                                           message:error.localizedDescription
                                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                                            [alert addAction:[UIAlertAction actionWithTitle:@"Got it" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                                                [self dismissViewControllerAnimated:YES completion:nil];
                                            }]];
                                            [self presentViewController:alert animated:YES completion:nil];
                                        }];
                                    } else {
                                        // User did not authenticate successfully, look at error and take appropriate action
                                    }
                                }];
        } else {
            Event *newEvent = [Event new];
            Channel *channel = [self.channelsArray objectAtIndex:[self.channelPickerView selectedRowInComponent:0]];
            newEvent.title = self.titleTextField.text;
            newEvent.eventDescription = self.descriptionTextField.text;
            newEvent.coordinates = self.pin.coordinate;
            newEvent.startTime = [NSDate date];
            newEvent.endTime = [NSDate dateWithTimeIntervalSinceNow:(3*60*60)];
            [APIHandler createEvent:newEvent inChannel:channel withSuccessHandler:^{
                [self dismissViewControllerAnimated:YES completion:nil];
            } failureHandler:^(NSError *error) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                               message:error.localizedDescription
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"Got it" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }]];
                [self presentViewController:alert animated:YES completion:nil];
            }];
        }
        
    }
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
    return [self.channelsArray count];
    
}

- (BOOL)_validateFields {
    return ([self.titleTextField.text length] && [self.descriptionTextField.text length] && self.pinAdded);
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
