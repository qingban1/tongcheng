#import "TYPassportViewController.h"
@implementation TYPassportViewController
- (void)renderContent {
    [super renderContent];
    [self addBackTitle:@"徒步护照"];
    NSDictionary *s = self.store.statistics, *p = self.store.state[@"profile"];
    [self add:[TYDesign card:@[
              [TYDesign label:@"我的山野护照" size:11 weight:UIFontWeightRegular],
              [TYDesign label:[NSString stringWithFormat:@"%@ · %@", p[@"nickname"], p[@"pace"]]
                         size:18
                       weight:UIFontWeightSemibold],
              [TYDesign label:[NSString stringWithFormat:@"%.2f km", [s[@"distance"] doubleValue]]
                         size:52
                       weight:UIFontWeightSemibold],
              [TYDesign label:[NSString stringWithFormat:@"%@段行程 · %@个活动日", s[@"count"], s[@"days"]]
                         size:13
                       weight:UIFontWeightRegular]
          ]
                        dark:YES]];
    [self addNote:@"统计包含标记为示例的初始行程；仅计时不增加距离，删除后重新计算。"];
    [self addSection:@"我的里程碑"];
    [self addNote:[s[@"count"] integerValue] > 0 ? @"✓ 已留下第一段山野" : @"等待第一次出发"];
    [self addSection:@"主题合集"];
    __weak typeof(self) w = self;
    for (NSDictionary *c in [self.store items:@"collections"]) {
        NSString *identifier = c[@"id"];
        [self addButton:c[@"title"]
                  style:@"outline"
                 action:^{
                     [w pushRoute:@"collection" identifier:identifier];
                 }];
    }
    [self addButton:@"创建主题合集"
              style:@"outline"
             action:^{
                 [w pushRoute:@"collectionEditor" identifier:nil];
             }];
}
@end
