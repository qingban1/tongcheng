#import "TYSquareViewController.h"
#import "TYCards.h"
@interface TYSquareViewController ()
@property(nonatomic, copy) NSString *feed;
@end
@implementation TYSquareViewController
- (void)renderContent {
    [super renderContent];
    self.feed = self.feed ?: @"推荐";
    __weak typeof(self) w = self;
    [self addTitle:@"广场"
           subtitle:@"同城徒遇 · 把周末还给山野"
        actionTitle:@"＋"
             action:^{
                 [w requireLoginForTitle:@"作品编辑"
                                  action:^{
                                      [w pushRoute:@"share" identifier:nil];
                                  }];
             }];
    [self addNote:@"设备内演示：社区人物、互动和活动均为示例，不提供跨设备社交通信。"];
    [self addChips:@[ @"推荐", @"关注" ]
          selected:self.feed
            action:^(NSString *t) {
                w.feed = t;
                [w renderContent];
            }];
    if ([self.feed isEqual:@"推荐"] && ![self.store containsIdentifier:@"cheng" in:@"blocked"]) {
        UIView *hero = [TYDesign hero:@"mountain"
                                title:@"把周末\n还给山野。"
                             subtitle:@"不赶路，也能遇见好风景 ↗"
                                badge:@"山野精选 · 示例作品"];
        [self add:[TYCards tappable:hero
                              label:@"把周末还给山野"
                             action:^{
                                 [w pushRoute:@"post" identifier:@"editorial"];
                             }]];
    }
    [self addSection:[self.feed isEqual:@"关注"] ? @"关注山友的作品" : @"最近的山野片刻"];
    NSInteger count = 0;
    for (NSDictionary *p in [self.store items:@"posts"]) {
        if (![p[@"status"] isEqual:@"public"] || [self.store containsIdentifier:p[@"author"] in:@"blocked"] ||
            ([self.feed isEqual:@"关注"] && ![self.store containsIdentifier:p[@"author"] in:@"following"]))
            continue;
        NSString *identifier = p[@"id"];
        [self add:[TYCards post:p
                         action:^{
                             [w pushRoute:@"post" identifier:identifier];
                         }]];
        count++;
    }
    if (!count)
        [self addNote:@"这里还没有作品。关注一位山友，或换到推荐看看。"];
}
@end
