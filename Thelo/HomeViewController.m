//
//  HomeViewController.m
//  Thelo
//
//  Created by Alex Stelea on 9/20/14.
//  Copyright (c) 2014 Alex Stelea. All rights reserved.
//

#import "HomeViewController.h"
#import "ChannelViewController.h"

@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *channelTable;
@end


@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.channelTable.delegate = self;
    self.channelTable.dataSource = self;
    self.channelTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [NotificationManager fireLocalNotificationWithMessage:[NSString stringWithFormat:@"Device ID: %@", DEVICE_ID]];
    [LocationManager registerRegionAtLatitude:33.777229 longitude:-84.396247 withRadius:300.0 andIdentifier:@"test notification"];
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
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"general"];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    return cell;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"channel select"]) {
        if ([segue.destinationViewController isKindOfClass:[ChannelViewController class]]) {
            ChannelViewController *cvc = (ChannelViewController *)segue.destinationViewController;
            UITableViewCell *cell = (UITableViewCell *)sender;
            cvc.channelName = cell.textLabel.text;
        }
    }
}

@end
