//
//  ChannelDetailViewController.m
//  Thelo
//
//  Created by Alex Stelea on 9/20/14.
//  Copyright (c) 2014 Alex Stelea. All rights reserved.
//

#import "ChannelDetailViewController.h"

@interface ChannelDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation ChannelDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = @"Free food";
    self.timeLabel.text = @"2 hours ago";
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:CLLocationCoordinate2DMake(33.776729599999996, -84.396323)];
    [annotation setTitle:@"Alex is here"];
    [self.mapView addAnnotation:annotation];
    
}

@end
