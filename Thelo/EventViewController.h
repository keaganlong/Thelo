//
//  ChannelDetailViewController.h
//  Thelo
//
//  Created by Alex Stelea on 9/20/14.
//  Copyright (c) 2014 Alex Stelea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Event.h"

@interface EventViewController : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) Event *event;

@end
