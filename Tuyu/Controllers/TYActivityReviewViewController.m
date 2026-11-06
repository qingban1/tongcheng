#import "TYActivityReviewViewController.h"
@implementation TYActivityReviewViewController
- (void)renderContent {
    [super renderContent];
    [self addBackTitle:@"活动审核状态"];
    NSDictionary *a = [self.store item:self.objectId in:@"activities"];
    if (!a) {
        [self addNote:@"还没有提交活动。"];
        return;
    }
    NSString *s = a[@"status"];
    [self add:[TYDesign card:@[
              [TYDesign
                   label:[s isEqual:@"approved"] ? @"活动已通过审核"
                                                 : ([s isEqual:@"rejected"] ? @"活动暂未通过，请完善信息。"
                                                                            : @"邀请已收到，审核后开始招募。")
                    size:28
                  weight:UIFontWeightBold],
              [TYDesign label:a[@"title"] size:18 weight:UIFontWeightSemibold],
              [TYDesign label:a[@"reason"] ?: @"本机演示审核" size:13 weight:UIFontWeightRegular]
          ]
                        dark:NO]];
    __weak typeof(self) w = self;
    if ([s isEqual:@"pending"]) {
        [self addButton:@"演示通过活动审核"
                  style:@""
                 action:^{
                     NSDictionary *v = [w.store item:w.objectId in:@"activities"];
                     if ([v[@"deadline"] doubleValue] <= NSDate.date.timeIntervalSince1970) {
                         [w showMessage:@"报名截止时间已过，请取消后重新发起。"];
                         return;
                     }
                     [w.store moderateActivity:w.objectId approved:YES];
                     [w renderContent];
                 }];
        [self addButton:@"演示未通过活动审核"
                  style:@"outline"
                 action:^{
                     [w.store moderateActivity:w.objectId approved:NO];
                     [w renderContent];
                 }];
    }
    if ([s isEqual:@"rejected"])
        [self addButton:@"修改活动后重新提交"
                  style:@""
                 action:^{
                     [w pushRoute:@"createActivity" identifier:w.objectId];
                 }];
    [self addButton:@"查看活动详情"
              style:@"outline"
             action:^{
                 [w pushRoute:@"activity" identifier:w.objectId];
             }];
}
@end
