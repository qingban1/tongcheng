#import "TYPostReviewViewController.h"
@implementation TYPostReviewViewController
- (void)renderContent {
    [super renderContent];
    [self addBackTitle:@"作品审核状态"];
    NSDictionary *p = [self.store item:self.objectId in:@"posts"];
    if (!p) {
        [self addNote:@"还没有提交作品。"];
        return;
    }
    NSString *s = p[@"status"], *title = @{
        @"pending" : @"故事已收到，审核后公开。",
        @"public" : @"作品已公开",
        @"rejected" : @"作品暂未通过，请修改内容。",
        @"removed" : @"作品已下架，不再公开展示。"
    }[s];
    [self add:[TYDesign card:@[
              [TYDesign label:title ?: @"作品状态" size:28 weight:UIFontWeightBold],
              [TYDesign label:p[@"title"] size:18 weight:UIFontWeightSemibold],
              [TYDesign label:p[@"reason"] ?: @"演示审核仅发生在本机，不会对外发布。"
                         size:13
                       weight:UIFontWeightRegular]
          ]
                        dark:NO]];
    __weak typeof(self) w = self;
    if ([s isEqual:@"pending"]) {
        [self addButton:@"演示通过作品审核"
                  style:@""
                 action:^{
                     [w.store moderatePost:w.objectId status:@"public"];
                     [w renderContent];
                 }];
        [self addButton:@"演示未通过作品审核"
                  style:@"outline"
                 action:^{
                     [w.store moderatePost:w.objectId status:@"rejected"];
                     [w renderContent];
                 }];
    } else if ([s isEqual:@"public"]) {
        [self addButton:@"演示下架作品"
                  style:@"outline"
                 action:^{
                     [w.store moderatePost:w.objectId status:@"removed"];
                     [w renderContent];
                 }];
    } else {
        [self addButton:@"修改后重新提交"
                  style:@""
                 action:^{
                     NSDictionary *post = [w.store item:w.objectId in:@"posts"];
                     NSMutableDictionary *d = [post mutableCopy];
                     d[@"editingId"] = w.objectId;
                     d[@"showMetrics"] = @(post[@"seconds"] != nil);
                     d[@"showTip"] = @([post[@"tip"] length] > 0);
                     w.store.state[@"draft"] = d;
                     [w.store commit];
                     [w pushRoute:@"share" identifier:nil];
                 }];
    }
    [self addButton:@"查看我的作品"
              style:@"outline"
             action:^{
                 [w pushRoute:@"myWorks" identifier:nil];
             }];
    [self addButton:@"回到广场"
              style:@"outline"
             action:^{
                 [w selectTab:0];
             }];
}
@end
