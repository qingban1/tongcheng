#import "TYRecordsViewController.h"
#import "TYCards.h"
@interface TYRecordsViewController ()
@property(nonatomic, strong) NSDate *selectedDate;
@end
@implementation TYRecordsViewController
- (void)renderContent {
    [super renderContent];
    self.screenMode = self.screenMode ?: @"行程";
    self.selectedDate = self.selectedDate ?: NSDate.date;
    __weak typeof(self) w = self;
    [self addTitle:@"记录"
           subtitle:@"每一步，都值得回看"
        actionTitle:@"护照"
             action:^{
                 [w pushRoute:@"passport" identifier:nil];
             }];
    NSDictionary *s = self.store.statistics;
    [self add:[TYDesign card:@[
              [TYDesign label:@"我的山野护照" size:11 weight:UIFontWeightRegular],
              [TYDesign label:[NSString stringWithFormat:@"%@ 段山野", s[@"count"]]
                         size:52
                       weight:UIFontWeightSemibold],
              [TYDesign label:[NSString stringWithFormat:@"%.2f km · %@个活动日",
                                                         [s[@"distance"] doubleValue], s[@"days"]]
                         size:13
                       weight:UIFontWeightRegular]
          ]
                        dark:YES]];
    [self addChips:@[ @"行程", @"月历", @"合集" ]
          selected:self.screenMode
            action:^(NSString *t) {
                w.screenMode = t;
                [w renderContent];
            }];
    if ([self.screenMode isEqual:@"合集"]) {
        [self addCollections];
        return;
    }
    if ([self.screenMode isEqual:@"月历"])
        [self addCalendar];
    NSInteger count = 0;
    for (NSDictionary *t in [self.store items:@"trips"]) {
        if ([self.screenMode isEqual:@"月历"] &&
            ![NSCalendar.currentCalendar
                         isDate:self.selectedDate
                inSameDayAsDate:[NSDate dateWithTimeIntervalSince1970:[t[@"start"] doubleValue]]])
            continue;
        NSString *identifier = t[@"id"];
        [self add:[TYCards trip:t
                         action:^{
                             [w pushRoute:@"journal" identifier:identifier];
                         }]];
        count++;
    }
    if (!count)
        [self addNote:[self.screenMode isEqual:@"月历"] ? @"选中日期没有徒步记录。"
                                                        : @"第一段山野，等你出发。"];
    [self addButton:@"开始新的徒步"
              style:@"outline"
             action:^{
                 [w selectTab:3];
             }];
}
- (void)addCollections {
    __weak typeof(self) w = self;
    for (NSDictionary *c in [self.store items:@"collections"]) {
        NSString *identifier = c[@"id"];
        [self
            add:[TYDesign card:@[
                [TYDesign label:c[@"title"] size:18 weight:UIFontWeightSemibold],
                [TYDesign
                     label:[NSString stringWithFormat:@"%lu段行程 · %@", (unsigned long)[c[@"tripIds"] count],
                                                      [c[@"public"] boolValue] ? @"公开摘要" : @"私人合集"]
                      size:12
                    weight:UIFontWeightRegular],
                [TYDesign button:@"打开合集"
                           style:@"outline"
                          action:^{
                              [w pushRoute:@"collection" identifier:identifier];
                          }]
            ]
                          dark:NO]];
    }
    [self addButton:@"创建主题合集"
              style:@"outline"
             action:^{
                 [w pushRoute:@"collectionEditor" identifier:nil];
             }];
}
- (void)addCalendar {
    NSCalendar *calendar = NSCalendar.currentCalendar;
    NSDateComponents *c = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth
                                      fromDate:self.selectedDate];
    NSDate *first = [calendar dateFromComponents:c];
    NSInteger days = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:first].length,
              offset = [calendar component:NSCalendarUnitWeekday fromDate:first] - 1;
    __weak typeof(self) w = self;
    [self add:[TYDesign horizontalStack:@[
              [TYDesign button:@"‹ 上月"
                         style:@"outline"
                        action:^{
                            w.selectedDate = [calendar dateByAddingUnit:NSCalendarUnitMonth
                                                                  value:-1
                                                                 toDate:first
                                                                options:0];
                            [w renderContent];
                        }],
              [TYDesign label:[NSString stringWithFormat:@"%ld年%ld月", (long)c.year, (long)c.month]
                         size:16
                       weight:UIFontWeightSemibold],
              [TYDesign button:@"下月 ›"
                         style:@"outline"
                        action:^{
                            w.selectedDate = [calendar dateByAddingUnit:NSCalendarUnitMonth
                                                                  value:1
                                                                 toDate:first
                                                                options:0];
                            [w renderContent];
                        }]
          ]]];
    NSMutableArray *week = [NSMutableArray new];
    for (NSString *d in @[ @"日", @"一", @"二", @"三", @"四", @"五", @"六" ]) {
        UILabel *l = [TYDesign label:d size:12 weight:UIFontWeightRegular];
        l.textAlignment = NSTextAlignmentCenter;
        [week addObject:l];
    }
    [self add:[TYDesign horizontalStack:week]];
    NSInteger cells = ((offset + days + 6) / 7) * 7;
    for (NSInteger row = 0; row < cells / 7; row++) {
        NSMutableArray *buttons = [NSMutableArray new];
        for (NSInteger col = 0; col < 7; col++) {
            NSInteger n = row * 7 + col - offset + 1;
            if (n < 1 || n > days) {
                [buttons addObject:[UIView new]];
                continue;
            }
            NSDate *date = [calendar dateByAddingUnit:NSCalendarUnitDay value:n - 1 toDate:first options:0];
            BOOL has = NO;
            for (NSDictionary *t in [self.store items:@"trips"])
                if ([calendar isDate:date
                        inSameDayAsDate:[NSDate dateWithTimeIntervalSince1970:[t[@"start"] doubleValue]]])
                    has = YES;
            TYActionButton *b = [TYDesign button:[NSString stringWithFormat:@"%ld", (long)n]
                                           style:has ? @"" : @"outline"
                                          action:^{
                                              w.selectedDate = date;
                                              [w renderContent];
                                          }];
            if ([calendar isDate:date inSameDayAsDate:self.selectedDate]) {
                b.layer.borderWidth = 2;
                b.layer.borderColor = [TYDesign color:@"9A3E0B"].CGColor;
            }
            [buttons addObject:b];
        }
        [self add:[TYDesign horizontalStack:buttons]];
    }
}
@end
