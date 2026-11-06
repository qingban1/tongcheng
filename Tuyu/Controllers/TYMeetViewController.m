#import "TYMeetViewController.h"
#import "TYCards.h"
@implementation TYMeetViewController
- (void)renderContent {
    [super renderContent];
    __weak typeof(self) w = self;
    [self addTitle:@"约行"
           subtitle:@"先对齐节奏，再遇见同行"
        actionTitle:@"＋"
             action:^{
                 [w pushRoute:@"createActivity" identifier:nil];
             }];
    [self addNote:@"活动与审核仅供设备内演示，不组织真实活动，请勿按示例地点集合。 "];
    TYActionButton *city = [TYDesign button:[NSString stringWithFormat:@"⌖ %@ ▾", self.store.state[@"city"]]
                                      style:@"soft"
                                     action:^{
                                         [w pushRoute:@"city" identifier:nil];
                                     }];
    [city.widthAnchor constraintEqualToConstant:105].active = YES;
    TYActionButton *mine = [TYDesign button:@"我的约行 ↗"
                                      style:@"link"
                                     action:^{
                                         [w pushRoute:@"myActivities" identifier:nil];
                                     }];
    [mine.widthAnchor constraintEqualToConstant:104].active = YES;
    UIView *spacer = [UIView new];
    UIStackView *topRow = [[UIStackView alloc] initWithArrangedSubviews:@[ city, spacer, mine ]];
    topRow.axis = UILayoutConstraintAxisHorizontal;
    topRow.alignment = UIStackViewAlignmentCenter;
    topRow.spacing = 8;
    [self add:topRow];
    [self add:[TYDesign card:@[
              [TYDesign label:@"同城 · 同步调" size:11 weight:UIFontWeightRegular],
              [TYDesign label:@"先选节奏，再遇同行。" size:28 weight:UIFontWeightBold],
              [TYDesign label:@"走得合拍，比走得快更重要。" size:12 weight:UIFontWeightRegular]
          ]
                        dark:YES]];
    [self addChips:@[ @"不限", @"轻松慢走", @"边走边拍", @"稳定行进" ]
          selected:self.store.state[@"pace"]
            action:^(NSString *t) {
                w.store.state[@"pace"] = t;
                [w.store commit];
                [w renderContent];
            }];
    UILabel *countLabel = [TYDesign label:@"同城出发" size:12 weight:UIFontWeightRegular];
    countLabel.textColor = TYDesign.muted;
    TYActionButton *filter = [TYDesign button:@"筛选约行"
                                        style:@"link"
                                       action:^{
                                           [w pushRoute:@"filter" identifier:nil];
                                       }];
    [filter.widthAnchor constraintEqualToConstant:88].active = YES;
    UIStackView *filterRow = [[UIStackView alloc] initWithArrangedSubviews:@[ countLabel, filter ]];
    filterRow.axis = UILayoutConstraintAxisHorizontal;
    filterRow.alignment = UIStackViewAlignmentCenter;
    [self add:filterRow];
    NSDictionary *f = self.store.state[@"filters"];
    NSInteger count = 0;
    for (NSDictionary *a in [self.store items:@"activities"]) {
        if (![a[@"status"] isEqual:@"approved"] || ![a[@"city"] isEqual:self.store.state[@"city"]] ||
            [self.store containsIdentifier:a[@"author"] in:@"blocked"])
            continue;
        NSString *pace = self.store.state[@"pace"];
        if (![pace isEqual:@"不限"] && ![pace isEqual:a[@"pace"]])
            continue;
        double days = ([a[@"date"] doubleValue] - NSDate.date.timeIntervalSince1970) / 86400,
               dist = [a[@"distance"] doubleValue];
        if ([f[@"date"] isEqual:@"未来7天"] && (days < 0 || days > 7))
            continue;
        if ([f[@"date"] isEqual:@"第8至14天"] && (days <= 7 || days > 14))
            continue;
        if ([f[@"distance"] isEqual:@"5公里内"] && dist > 5)
            continue;
        if ([f[@"distance"] isEqual:@"5至10公里"] && (dist <= 5 || dist > 10))
            continue;
        if ([f[@"distance"] isEqual:@"10公里以上"] && dist <= 10)
            continue;
        if ([f[@"available"] boolValue] && ![[self.store statusForActivity:a] isEqual:@"招募中"])
            continue;
        NSString *identifier = a[@"id"];
        [self add:[TYCards activity:a
                             action:^{
                                 [w pushRoute:@"activity" identifier:identifier];
                             }]];
        count++;
    }
    countLabel.text =
        [NSString stringWithFormat:@"%ld场约行 · %@ · %@", (long)count, f[@"date"], f[@"distance"]];
    if (!count)
        [self addNote:@"没有符合条件的约行，试试调整节奏、城市或筛选条件。"];
}
@end
