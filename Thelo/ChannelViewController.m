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

@interface ChannelViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *channelLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *notificationRadiusControl;
@property (weak, nonatomic) IBOutlet UITableView *channelTable;
@property (weak, nonatomic) IBOutlet UILabel *radius;
@property (weak, nonatomic) IBOutlet UIButton *subscribedButton;
@property (strong, nonatomic) NSArray *events;
@end

@implementation ChannelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.channelLabel.text = self.channel.name;
    [_notificationRadiusControl addTarget:self action:@selector(sliderChanged:)
       forControlEvents:UIControlEventValueChanged];
    self.channelTable.delegate = self;
    self.channelTable.dataSource = self;
    self.channelTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [APIHandler getEventsForChannel:self.channel withSuccessHandler:^(NSArray *events) {
        self.events = events;
        [self.channelTable reloadData];
    } failureHandler:nil];
    [self.subscribedButton setTitle:(self.channel.subscribed ? @"Subscribed √" : @"Not Subscribed") forState: UIControlStateNormal];
    [self _selectSegmentedControlSegment];
}

- (void)viewWillAppear:(BOOL)animated {
    [APIHandler getEventsForChannel:self.channel withSuccessHandler:^(NSArray *events) {
        self.events = events;
        [self.channelTable reloadData];
    } failureHandler:nil];
}

- (IBAction)subscribeChange:(id)sender {
    if (!self.channel.subscribed) {
        [self.subscribedButton setTitle: @"Subscribed √" forState: UIControlStateNormal];
        self.channel.subscribed = YES;
        [APIHandler subscribeToChannel:self.channel withSuccessHandler:nil failureHandler:nil];
    }
    else {
        [self.subscribedButton setTitle: @"Not Subscribed" forState: UIControlStateNormal];
        self.channel.subscribed = NO;
        [APIHandler unsubscribeFromChannel:self.channel withSuccessHandler:nil failureHandler:nil];
    }
}

#pragma mark - ARC
- (void)setChannel:(Channel *)channel {
    _channel = channel;
    self.title = channel.name;
}

-(IBAction)sliderChanged:(id)sender{
   _radius.text = [_notificationRadiusControl titleForSegmentAtIndex:_notificationRadiusControl.selectedSegmentIndex];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"general"];
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
