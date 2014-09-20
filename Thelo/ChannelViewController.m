//
//  ChannelViewController.m
//  
//
//  Created by Alex Stelea on 9/20/14.
//
//

#import "ChannelViewController.h"

@interface ChannelViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation ChannelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - ARC
- (void)setChannelName:(NSString *)channelName {
    _channelName = channelName;
    self.title = channelName;
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
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row];
    return cell;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"channel select"]) {
        if ([segue.destinationViewController isKindOfClass:[ChannelViewController class]]) {
            
        }
    }
}

@end
