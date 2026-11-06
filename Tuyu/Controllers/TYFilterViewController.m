#import "TYFilterViewController.h"
@implementation TYFilterViewController
- (void)viewDidLoad {
    self.values = [self.store.state[@"filters"] mutableCopy];
    self.values[@"pace"] = self.store.state[@"pace"];
    [super viewDidLoad];
}
- (void)renderContent {
    [super renderContent];
    [self addBackTitle:@"约行筛选"];
    [self addChoice:@"出发日期" key:@"date" options:@[ @"不限", @"未来7天", @"第8至14天" ] initial:@"不限"];
    [self addChoice:@"预计距离"
                key:@"distance"
            options:@[ @"不限", @"5公里内", @"5至10公里", @"10公里以上" ]
            initial:@"不限"];
    [self addChoice:@"同行节奏"
                key:@"pace"
            options:@[ @"不限", @"轻松慢走", @"边走边拍", @"稳定行进" ]
            initial:@"不限"];
    [self addSwitch:@"只看可报名活动" key:@"available" initial:NO];
    __weak typeof(self) w = self;
    [self addButton:@"应用筛选"
              style:@""
             action:^{
                 w.store.state[@"filters"] = [@{
                     @"date" : w.values[@"date"],
                     @"distance" : w.values[@"distance"],
                     @"available" : w.values[@"available"]
                 } mutableCopy];
                 w.store.state[@"pace"] = w.values[@"pace"];
                 [w.store commit];
                 [w.navigationController popViewControllerAnimated:YES];
             }];
    [self addButton:@"重置筛选"
              style:@"outline"
             action:^{
                 w.values =
                     [@{@"date" : @"不限",
                        @"distance" : @"不限",
                        @"pace" : @"不限",
                        @"available" : @NO} mutableCopy];
                 [w renderContent];
             }];
}
@end
