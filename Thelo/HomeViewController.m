//
//  HomeViewController.m
//  Thelo
//
//  Created by Alex Stelea on 9/20/14.
//  Copyright (c) 2014 Alex Stelea. All rights reserved.
//

#import "HomeViewController.h"
#import "ChannelViewController.h"
#import "Channel.h"

@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *channelTable;
@property (strong, nonatomic) NSArray *channels;
@end


@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.channelTable.delegate = self;
    self.channelTable.dataSource = self;
    self.channelTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [NotificationManager fireLocalNotificationWithMessage:[NSString stringWithFormat:@"Device ID: %@", DEVICE_ID]];
    NSLog(@"Currently at: %@", [LocationManager currentLocation]);
    [LocationManager registerRegionAtLatitude:33.777229 longitude:-84.396247 withRadius:300.0 andIdentifier:@"Klaus"];
    [APIHandler getChannelsWithSuccessHandler:^(NSArray *newChannels) {
        self.channels = newChannels;
        [self.channelTable reloadData];
    } failureHandler:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [APIHandler getChannelsWithSuccessHandler:^(NSArray *newChannels) {
        self.channels = newChannels;
        [self.channelTable reloadData];
    } failureHandler:nil];

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
    return [self.channels count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"general"];
    Channel *channel = [self.channels objectAtIndex:indexPath.row];
    cell.textLabel.text = channel.name;
    return cell;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"channel select"]) {
        if ([segue.destinationViewController isKindOfClass:[ChannelViewController class]]) {
            ChannelViewController *cvc = (ChannelViewController *)segue.destinationViewController;
            UITableViewCell *cell = (UITableViewCell *)sender;
            NSIndexPath *indexPath = [self.channelTable indexPathForCell:cell];
            cvc.channel = [self.channels objectAtIndex:indexPath.row];
        }
    }
}

@end
