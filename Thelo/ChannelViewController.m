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
    _notificationRadiusControl.selectedFont = [UIFont boldFlatFontOfSize:12];
    _notificationRadiusControl.selectedFontColor = [UIColor cloudsColor];
    _notificationRadiusControl.deselectedFont = [UIFont flatFontOfSize:12];
    _notificationRadiusControl.deselectedFontColor = [UIColor cloudsColor];
    _notificationRadiusControl.selectedColor = [UIColor midnightBlueColor];
    _notificationRadiusControl.deselectedColor = [UIColor silverColor];
    _notificationRadiusControl.dividerColor = [UIColor midnightBlueColor];
    _notificationRadiusControl.cornerRadius = 12.0;
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
    } failureHandler:nil];

    [self _selectSegmentedControlSegment];
    [self.subscribedSwitch setOn:self.channel.subscribed];
}

- (void)viewWillAppear:(BOOL)animated {
    [APIHandler getEventsForChannel:self.channel withSuccessHandler:^(NSArray *events) {
        self.events = events;
        [self.channelTable reloadData];
    } failureHandler:nil];
}

- (IBAction)subscribeChange:(id)sender {
    if (!self.channel.subscribed) {
        self.notificationRadiusControl.hidden = NO;
        self.notificationRadiusText.hidden = NO;
        self.notificationText.text = @"Subscribed!";
        self.channel.subscribed = YES;
        [self.subscribedSwitch setOn:self.channel.subscribed];
        [APIHandler subscribeToChannel:self.channel withSuccessHandler:nil failureHandler:nil];
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
    cell.textLabel.text = event.title;
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

@end
