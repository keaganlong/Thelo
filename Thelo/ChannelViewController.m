//
//  ChannelViewController.m
//  
//
//  Created by Alex Stelea on 9/20/14.
//
//

#import "ChannelViewController.h"
#import "ChannelDetailViewController.h"

@interface ChannelViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *channelLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *notificationRadiusControl;
@property (weak, nonatomic) IBOutlet UITableView *channelTable;
@property (weak, nonatomic) IBOutlet UILabel *radius;
@property (weak, nonatomic) IBOutlet UIButton *subscribedButton;
@property (nonatomic) BOOL subscribed;
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
}
- (IBAction)subscribeChange:(id)sender {
    if (!self.subscribed) {
        [self.subscribedButton setTitle: @"Not Subscribed" forState: UIControlStateNormal];
        self.subscribed = YES;
    }
    else {
        [self.subscribedButton setTitle: @"Subscribed √" forState: UIControlStateNormal];
        self.subscribed = NO;

    }
}

#pragma mark - ARC
- (void)setChannel:(Channel *)channel {
    _channel = channel;
    self.title = channel.name;
}

-(IBAction)sliderChanged:(id)sender{
   _radius.text = [_notificationRadiusControl titleForSegmentAtIndex:_notificationRadiusControl.selectedSegmentIndex];
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
    if ([segue.identifier isEqualToString:@"event select"]) {
        if ([segue.destinationViewController isKindOfClass:[ChannelDetailViewController class]]) {
            NSLog(@"We push to chanel view controller");
        }
    }
}

@end
