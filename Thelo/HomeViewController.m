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
@property (strong, nonatomic) NSArray *unsubbedChannels;
@property (strong, nonatomic) NSArray *subbedChannels;
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
        [APIHandler getSubscribedChannelsWithSuccessHandler:^(NSArray *subbedChannels) {
            NSMutableArray *unsubbedChannels = [NSMutableArray new];
            for (Channel *unsubbedChannel in newChannels) {
                BOOL matched = NO;
                for (Channel *subbedChannel in subbedChannels) {
                    if ([subbedChannel.name isEqualToString:unsubbedChannel.name]) {
                        matched = YES;
                    }
                }
                if (!matched) {
                    [unsubbedChannels addObject:unsubbedChannel];
                }
            }
            self.unsubbedChannels = unsubbedChannels;
            self.subbedChannels = subbedChannels;
            [self.channelTable reloadData];
        } failureHandler:nil];
    } failureHandler:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [APIHandler getChannelsWithSuccessHandler:^(NSArray *newChannels) {
        [APIHandler getSubscribedChannelsWithSuccessHandler:^(NSArray *subbedChannels) {
            NSMutableArray *unsubbedChannels = [NSMutableArray new];
            for (Channel *unsubbedChannel in newChannels) {
                BOOL matched = NO;
                for (Channel *subbedChannel in subbedChannels) {
                    if ([subbedChannel.name isEqualToString:unsubbedChannel.name]) {
                        matched = YES;
                    }
                }
                if (!matched) {
                    [unsubbedChannels addObject:unsubbedChannel];
                }
            }
            self.unsubbedChannels = unsubbedChannels;
            self.subbedChannels = subbedChannels;
            [self.channelTable reloadData];
        } failureHandler:nil];
    } failureHandler:nil];

}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Subscribed channels";
    } else {
        return @"Other channels";
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.subbedChannels count];
    } else {
        return [self.unsubbedChannels count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"general"];
    Channel *channel;
    if (indexPath.section == 0) {
        channel = [self.subbedChannels objectAtIndex:indexPath.row];
    } else {
        channel = [self.unsubbedChannels objectAtIndex:indexPath.row];
    }
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
            if (indexPath.section == 0) {
                cvc.channel = [self.subbedChannels objectAtIndex:indexPath.row];
            } else {
                cvc.channel = [self.unsubbedChannels objectAtIndex:indexPath.row];
            }
        }
    }
}

@end
