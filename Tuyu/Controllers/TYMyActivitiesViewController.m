#import "TYMyActivitiesViewController.h"
@implementation TYMyActivitiesViewController
- (void)renderContent {
    [super renderContent];
    self.screenMode = self.screenMode ?: @"我报名的";
    [self addBackTitle:@"我的约行"];
    __weak typeof(self) w = self;
    [self addChips:@[ @"我报名的", @"我发起的" ]
          selected:self.screenMode
            action:^(NSString *t) {
                w.screenMode = t;
                [w renderContent];
            }];
    NSInteger count = 0;
    for (NSDictionary *a in [self.store items:@"activities"]) {
        BOOL mine = [a[@"author"] isEqual:@"self"];
        NSString *s = [self.store applicationStatus:a[@"id"]];
        if ([self.screenMode isEqual:@"我发起的"] ? !mine : [s isEqual:@"none"])
            continue;
        NSString *identifier = a[@"id"];
        [self
            add:[TYDesign card:@[
                [TYDesign
                    pill:mine ? [self.store statusForActivity:a]
                              : (@{@"pending" : @"等待审核",
                                   @"approved" : @"已通过",
                                   @"rejected" : @"未通过"}[s]
                                     ?: s)],
                [TYDesign label:a[@"title"] size:18 weight:UIFontWeightSemibold],
                [TYDesign label:[TYLocalStore dateText:a[@"date"]] size:12 weight:UIFontWeightRegular],
                [TYDesign button:@"查看活动"
                           style:@""
                          action:^{
                              [w pushRoute:@"activity" identifier:identifier];
                          }]
            ]
                          dark:NO]];
        if (mine)
            [self addButton:@"报名管理"
                      style:@"outline"
                     action:^{
                         [w pushRoute:@"participants" identifier:identifier];
                     }];
        count++;
    }
    if (!count)
        [self addNote:@"这里还没有约行，可以去同城活动寻找同行者，也可以自己发起。"];
    [self addButton:@"发起新的约行"
              style:@"outline"
             action:^{
                 [w pushRoute:@"createActivity" identifier:nil];
             }];
}
@end
