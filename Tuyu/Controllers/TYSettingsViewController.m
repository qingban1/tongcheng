#import "TYSettingsViewController.h"
#import "TYCards.h"
#import "TYLocalAuthService.h"
@implementation TYSettingsViewController
- (void)renderContent {
    [super renderContent];
    [self addBackTitle:@"设置"];
    __weak typeof(self) w = self;
    NSArray *rows = @[
        @[ @"个人资料", @"profile" ], @[ @"隐私说明", @"privacy" ], @[ @"定位与记录说明", @"permission" ],
        @[ @"屏蔽名单", @"blocked" ], @[ @"社区规范", @"guidelines" ], @[ @"帮助与反馈", @"feedback" ]
    ];
    NSDictionary *symbols = @{
        @"profile" : @"person.crop.circle",
        @"privacy" : @"shield",
        @"permission" : @"location",
        @"blocked" : @"person.2",
        @"guidelines" : @"flag",
        @"feedback" : @"square.and.pencil"
    };
    UIStackView *menu = TYDesign.verticalStack;
    menu.spacing = 0;
    for (NSArray *r in rows)
        [menu addArrangedSubview:[TYCards menuRow:r[0]
                                         subtitle:@""
                                           symbol:symbols[r[1]]
                                           action:^{
                                               [w pushRoute:r[1] identifier:nil];
                                           }]];
    [self add:[TYDesign card:@[ menu ] dark:NO]];
    [self addNote:[NSString stringWithFormat:@"本机演示账号：%@。不发送短信，不同步账号或数据。",
                                             TYLocalAuthService.sharedService.maskedPhone ?: @"未登录"]];
    [self addButton:@"退出登录"
              style:@"outline"
             action:^{
                 [w confirm:@"退出演示登录"
                       text:@"本机数据将保留，进行中的徒步会暂停。"
                     action:^{
                         [w returnToGuestSquare];
                     }];
             }];
    [self addToggle:@"使用真实GPS记录" key:@"realTracking"];
    [self addNote:
              @"默认关闭以保持原型示例模式。开启后点击开始徒步才请求定位；拒绝权限仍可计时，不会伪造距离。"];
    [self addToggle:@"活动通知偏好" key:@"notifications"];
    [self addNote:@"通知偏好仅保存到本机，站内消息始终可用，不会发送系统推送。"];
    [self addButton:@"清除本机资料与记录"
              style:@"danger"
             action:^{
                 [w pushRoute:@"deleteData" identifier:nil];
             }];
    [self addButton:@"重置演示数据"
              style:@"outline"
             action:^{
                 [w pushRoute:@"reset" identifier:nil];
             }];
#if DEBUG
    [self addButton:@"界面状态预览"
              style:@"outline"
             action:^{
                 [w pushRoute:@"states" identifier:nil];
             }];
#endif
}
- (void)addToggle:(NSString *)title key:(NSString *)key {
    UISwitch *s = [UISwitch new];
    s.translatesAutoresizingMaskIntoConstraints = NO;
    s.on = [self.store.state[key] boolValue];
    s.onTintColor = TYDesign.deep;
    s.accessibilityLabel = title;
    s.accessibilityIdentifier = key;
    [s addTarget:self action:@selector(toggleChanged:) forControlEvents:UIControlEventValueChanged];
    UILabel *l = [TYDesign label:title size:15 weight:UIFontWeightRegular];
    UIStackView *r = [[UIStackView alloc] initWithArrangedSubviews:@[ l, s ]];
    r.axis = UILayoutConstraintAxisHorizontal;
    r.spacing = 12;
    r.alignment = UIStackViewAlignmentCenter;
    [self add:r];
}
- (void)toggleChanged:(UISwitch *)sender {
    self.store.state[sender.accessibilityIdentifier] = @(sender.on);
    [self.store commit];
}
@end
