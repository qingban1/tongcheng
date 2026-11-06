#import "TYMineViewController.h"
#import "TYCards.h"
@implementation TYMineViewController
- (void)renderContent {
    [super renderContent];
    __weak typeof(self) w = self;
    [self addTitle:@"我的"
           subtitle:@"我的山野，由我管理"
        actionTitle:@"设置"
             action:^{
                 [w pushRoute:@"settings" identifier:nil];
             }];
    NSDictionary *profile = self.store.state[@"profile"], *statistics = self.store.statistics;
    NSUInteger postCount =
        [[self.store items:@"posts"]
            filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"author == %@", @"self"]]
            .count;
    [self
        add:[TYDesign card:@[
            [TYDesign person:profile[@"nickname"]
                    subtitle:[NSString stringWithFormat:@"%@ · %@", profile[@"city"], profile[@"pace"]]],
            [TYDesign button:@"编辑个人资料"
                       style:@"gradient"
                      action:^{
                          [w pushRoute:@"profile" identifier:nil];
                      }],
            [TYDesign label:[NSString stringWithFormat:@"%@段徒步 · %lu篇作品 · %lu个合集",
                                                       statistics[@"count"], (unsigned long)postCount,
                                                       (unsigned long)[self.store items:@"collections"].count]
                       size:13
                     weight:UIFontWeightRegular]
        ]
                      dark:YES]];
    NSArray *rows = @[
        @[ @"徒步护照", @"回看每一次出发", @"calendar", @"passport" ],
        @[ @"我的约行", @"报名、发起与活动管理", @"person.2", @"myActivities" ],
        @[ @"消息中心", @"活动结果和系统通知", @"bell", @"messages" ],
        @[ @"我的作品", @"公开、审核中与草稿", @"photo", @"myWorks" ],
        @[ @"我的收藏", @"下次出发的灵感", @"bookmark", @"favorites" ],
        @[ @"复盘档案", @"留给下次的经验", @"square.and.pencil", @"reviews" ]
    ];
    UIStackView *menu = TYDesign.verticalStack;
    menu.spacing = 0;
    for (NSArray *row in rows)
        [menu addArrangedSubview:[TYCards menuRow:row[0]
                                         subtitle:row[1]
                                           symbol:row[2]
                                           action:^{
                                               [w pushRoute:row[3] identifier:nil];
                                           }]];
    [self add:[TYDesign card:@[ menu ] dark:NO]];
    [self addButton:@"隐私与本机数据设置"
              style:@"outline"
             action:^{
                 [w pushRoute:@"settings" identifier:nil];
             }];
}
@end
