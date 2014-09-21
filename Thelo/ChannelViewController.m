//
//  ChannelViewController.m
//  
//
//  Created by Alex Stelea on 9/20/14.
//
//

#import "ChannelViewController.h"
#import "EventViewController.h"
#import "Event.h"
#import "UIColor+FlatUI.h"
#import "UISlider+FlatUI.h"
#import "UIStepper+FlatUI.h"
#import "UITabBar+FlatUI.h"
#import "UINavigationBar+FlatUI.h"
#import "FUIButton.h"
#import "FUISwitch.h"
#import "UIFont+FlatUI.h"
#import "FUIAlertView.h"
#import "UIBarButtonItem+FlatUI.h"
#import "UIProgressView+FlatUI.h"
#import "UIFont+FlatUI.h"
#import "FUISegmentedControl.h"
#import "UITableViewCell+FlatUI.h"
@interface ChannelViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *channelLabel;
@property (weak, nonatomic) IBOutlet FUISegmentedControl *notificationRadiusControl;
@property (weak, nonatomic) IBOutlet UITableView *channelTable;
@property (weak, nonatomic) IBOutlet FUISwitch *subscribedSwitch;
@property (weak, nonatomic) IBOutlet UILabel *notificationText;
@property (weak, nonatomic) IBOutlet UILabel *notificationRadiusText;
@property (strong, nonatomic) NSArray *events;
@end


@implementation ChannelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.channelLabel.text = self.channel.name;
    self.notificationText.text = self.channel.subscribed ? @"Subscribed!" : @"Unsubscribed!";
    self.notificationRadiusControl.hidden = !self.channel.subscribed;
    self.notificationRadiusText.hidden = !self.channel.subscribed;
    _notificationRadiusControl.selectedFont = [UIFont boldFlatFontOfSize:10];
    _notificationRadiusControl.selectedFontColor = [UIColor cloudsColor];
    _notificationRadiusControl.deselectedFont = [UIFont flatFontOfSize:10];
    _notificationRadiusControl.deselectedFontColor = [UIColor cloudsColor];
    _notificationRadiusControl.selectedColor = [UIColor midnightBlueColor];
    _notificationRadiusControl.deselectedColor = [UIColor silverColor];
    _notificationRadiusControl.dividerColor = [UIColor midnightBlueColor];
    _notificationRadiusControl.cornerRadius = 15.0;
    _subscribedSwitch.onColor = [UIColor turquoiseColor];
    _subscribedSwitch.offColor = [UIColor cloudsColor];
    _subscribedSwitch.onBackgroundColor = [UIColor midnightBlueColor];
    _subscribedSwitch.offBackgroundColor = [UIColor silverColor];
    _subscribedSwitch.offLabel.font = [UIFont boldFlatFontOfSize:14];
    _subscribedSwitch.onLabel.font = [UIFont boldFlatFontOfSize:14];
    [_notificationRadiusControl addTarget:self action:@selector(sliderChanged:)
       forControlEvents:UIControlEventValueChanged];
    self.channelTable.delegate = self;
    self.channelTable.dataSource = self;
    self.channelTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [APIHandler getEventsForChannel:self.channel withSuccessHandler:^(NSArray *events) {
        self.events = events;
        [self.channelTable reloadData];
        for (Event *event in events) {
            [APIHandler getIntentToAttendCountForEvent:event withSuccessHandler:^(NSNumber *count) {
                [APIHandler getAttendCountForEvent:event withSuccessHandler:^(NSNumber *attendCount) {
                    event.goingCount = [NSNumber numberWithInt:([count intValue] + [attendCount intValue])];
                    [self.channelTable reloadData];
                } failureHandler:nil];
            } failureHandler:nil];
        }
    } failureHandler:nil];

    [self _selectSegmentedControlSegment];
    [self.subscribedSwitch setOn:self.channel.subscribed];
}

- (void)viewWillAppear:(BOOL)animated {
    [APIHandler getEventsForChannel:self.channel withSuccessHandler:^(NSArray *events) {
        self.events = events;
        [self.channelTable reloadData];
        for (Event *event in events) {
            [APIHandler getIntentToAttendCountForEvent:event withSuccessHandler:^(NSNumber *count) {
                [APIHandler getAttendCountForEvent:event withSuccessHandler:^(NSNumber *attendCount) {
                    event.goingCount = [NSNumber numberWithInt:([count intValue] + [attendCount intValue])];
                    [self.channelTable reloadData];
                } failureHandler:nil];
            } failureHandler:nil];
        }
    } failureHandler:nil];
}

- (IBAction)subscribeChange:(id)sender {
    if (!self.channel.subscribed) {
        self.notificationRadiusControl.hidden = NO;
        self.notificationRadiusText.hidden = NO;
        self.notificationText.text = @"Subscribed!";
        self.channel.subscribed = YES;
        [self.subscribedSwitch setOn:self.channel.subscribed];
        [APIHandler subscribeToChannel:self.channel withSuccessHandler:^{
            [LocationManager forceMonitoredRegionsUpdate];
        } failureHandler:nil];
    }
    else {
        self.channel.subscribed = NO;
        [self.subscribedSwitch setOn:self.channel.subscribed];

        self.notificationText.text = @"Unsubscribed!";
        self.notificationRadiusControl.hidden = YES;
        self.notificationRadiusText.hidden = YES;

        [APIHandler unsubscribeFromChannel:self.channel withSuccessHandler:nil failureHandler:nil];
    }
}

#pragma mark - ARC
- (void)setChannel:(Channel *)channel {
    _channel = channel;
    self.title = channel.name;
}

-(IBAction)sliderChanged:(id)sender{
    switch (self.notificationRadiusControl.selectedSegmentIndex) {
        case 0:
            self.channel.notificationRadius = 50;
            break;
        case 1:
            self.channel.notificationRadius = 100;
            break;
        case 2:
            self.channel.notificationRadius = 250;
            break;
        case 3:
            self.channel.notificationRadius = 500;
            break;
        case 4:
            self.channel.notificationRadius = 1000;
            break;
        default:
            self.channel.notificationRadius = 50;
            break;
    }
    [LocationManager forceMonitoredRegionsUpdate];
}

- (void)_selectSegmentedControlSegment {
    switch (self.channel.notificationRadius) {
        case 50:
            self.notificationRadiusControl.selectedSegmentIndex = 0;
            break;
        case 100:
            self.notificationRadiusControl.selectedSegmentIndex = 1;
            break;
        case 250:
            self.notificationRadiusControl.selectedSegmentIndex = 2;
            break;
        case 500:
            self.notificationRadiusControl.selectedSegmentIndex = 3;
            break;
        case 1000:
            self.notificationRadiusControl.selectedSegmentIndex = 4;
            break;
        default:
            self.notificationRadiusControl.selectedSegmentIndex = 0;
            break;
    }

}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.events count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"general-event"];
 
    Event *event = [self.events objectAtIndex:indexPath.row];
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
    titleLabel.text = event.title;
    UILabel *descriptionLabel = (UILabel *)[cell viewWithTag:101];
    descriptionLabel.text = [self _dateDiff:event.startTime];


    UILabel *peopleGoingText = (UILabel *)[cell viewWithTag:102];

    peopleGoingText.text = [event.goingCount stringValue];
    return cell;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"event select"]) {
        if ([segue.destinationViewController isKindOfClass:[EventViewController class]]) {
            EventViewController *evc = (EventViewController *)segue.destinationViewController;
            UITableViewCell *cell = (UITableViewCell *)sender;
            NSIndexPath *indexPath = [self.channelTable indexPathForCell:cell];
            evc.event = [self.events objectAtIndex:indexPath.row];
        }
    }
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
