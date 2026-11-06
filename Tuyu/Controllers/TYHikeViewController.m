#import "TYHikeViewController.h"
#import "TYTrackingService.h"
@implementation TYHikeViewController
- (void)renderContent {
    [super renderContent];
    __weak typeof(self) w = self;
    [self addTitle:@"徒步"
           subtitle:@"以自己的节奏出发"
        actionTitle:@"说明"
             action:^{
                 [w pushRoute:@"permission" identifier:nil];
             }];
    [self add:[TYDesign label:@"不必赶路，\n现在出发。" size:37 weight:UIFontWeightBold]];
    TYTrackingService *service = TYTrackingService.sharedService;
    NSDictionary *s = service.session;
    if (s) {
        [self add:[TYDesign card:@[
                  [TYDesign label:[s[@"needsRecovery"] boolValue] ? @"发现未结束的记录" : @"本次徒步尚未结束"
                             size:22
                           weight:UIFontWeightSemibold],
                  [TYDesign label:[TYLocalStore durationText:service.elapsedSeconds]
                             size:36
                           weight:UIFontWeightSemibold],
                  [TYDesign button:[s[@"needsRecovery"] boolValue] ? @"恢复上次记录" : @"返回进行中的记录"
                             style:@"gradient"
                            action:^{
                                [w pushRoute:[s[@"needsRecovery"] boolValue] ? @"recovery" : @"tracking"
                                    identifier:nil];
                            }]
              ]
                            dark:YES]];
    } else {
        [self add:[TYDesign mapWithPoints:nil example:YES]];
        NSString *linked = self.store.state[@"linkedActivityId"];
        NSDictionary *a = [self.store item:linked in:@"activities"];
        if (a && [self.store canAccessActivity:a])
            [self addNote:[@"已关联：" stringByAppendingString:a[@"title"]]];
        else
            [self addButton:@"关联已通过的约行"
                      style:@"outline"
                     action:^{
                         [w pushRoute:@"myActivities" identifier:nil];
                     }];
        BOOL real = [self.store.state[@"realTracking"] boolValue];
        [self addNote:real ? @"开始后按需申请定位。估算距离与本机轨迹仅供回顾，不用于导航。"
                           : @"示例模式不采集位置，固定距离不会被描述为实际步行。"];
        [self addButton:real ? @"开始徒步" : @"开始示例徒步"
                  style:@""
                 action:^{
                     [service startMode:real ? @"真实轨迹" : @"示例轨迹" activityId:linked];
                     [w pushRoute:@"tracking" identifier:nil];
                 }];
        [self addButton:@"仅计时模式"
                  style:@"outline"
                 action:^{
                     [service startMode:@"仅计时" activityId:linked];
                     [w pushRoute:@"tracking" identifier:nil];
                 }];
    }
    [self addButton:@"定位与记录说明"
              style:@"outline"
             action:^{
                 [w pushRoute:@"permission" identifier:nil];
             }];
}
@end
