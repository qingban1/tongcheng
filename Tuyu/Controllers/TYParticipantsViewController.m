#import "TYParticipantsViewController.h"
@implementation TYParticipantsViewController
- (void)renderContent {
    [super renderContent];
    [self addBackTitle:@"报名管理"];
    NSMutableDictionary *a = [self.store item:self.objectId in:@"activities"];
    if (![a[@"author"] isEqual:@"self"]) {
        [self addNote:@"仅发起人可以管理报名。"];
        return;
    }
    self.screenMode = self.screenMode ?: @"待审核";
    __weak typeof(self) w = self;
    [self add:[TYDesign card:@[
              [TYDesign label:a[@"title"] size:20 weight:UIFontWeightSemibold],
              [TYDesign label:[NSString stringWithFormat:@"已确认%@人 / 上限%@人 · %@", a[@"joined"],
                                                         a[@"capacity"], [self.store statusForActivity:a]]
                         size:13
                       weight:UIFontWeightRegular]
          ]
                        dark:YES]];
    [self addChips:@[ @"待审核", @"已通过", @"未通过" ]
          selected:self.screenMode
            action:^(NSString *t) {
                w.screenMode = t;
                [w renderContent];
            }];
    NSString *status =
        @{@"待审核" : @"pending", @"已通过" : @"approved", @"未通过" : @"rejected"}[self.screenMode];
    NSInteger count = 0;
    for (NSDictionary *r in [self.store items:@"requests"]) {
        if (![r[@"activityId"] isEqual:self.objectId] || ![r[@"status"] isEqual:status])
            continue;
        NSString *identifier = r[@"id"];
        NSMutableArray *views = [NSMutableArray arrayWithArray:@[
            [TYDesign person:r[@"name"] subtitle:r[@"pace"]], [TYDesign label:r[@"note"]
                                                                         size:14
                                                                       weight:UIFontWeightRegular]
        ]];
        if ([status isEqual:@"pending"] && ![a[@"cancelled"] boolValue]) {
            [views addObject:[TYDesign horizontalStack:@[
                       [TYDesign button:@"不通过"
                                  style:@"outline"
                                 action:^{
                                     NSError *e;
                                     if ([w.store decideRequest:identifier approved:NO error:&e])
                                         [w renderContent];
                                     else
                                         [w showError:e];
                                 }],
                       [TYDesign button:@"通过申请"
                                  style:@""
                                 action:^{
                                     NSError *e;
                                     if ([w.store decideRequest:identifier approved:YES error:&e])
                                         [w renderContent];
                                     else
                                         [w showError:e];
                                 }]
                   ]]];
        }
        [self add:[TYDesign card:views dark:NO]];
        count++;
    }
    if (!count)
        [self addNote:@"当前分组暂无报名。"];
    if ([[self.store statusForActivity:a] isEqual:@"招募中"])
        [self addButton:@"添加示例报名"
                  style:@"outline"
                 action:^{
                     [w.store.state[@"requests"] addObject:[@{
                                                     @"id" : TYLocalStore.identifier,
                                                     @"activityId" : w.objectId,
                                                     @"name" : @"小林",
                                                     @"pace" : @"边走边拍",
                                                     @"note" : @"这是一条本机示例申请。",
                                                     @"status" : @"pending"
                                                 } mutableCopy]];
                     [w.store commit];
                     w.screenMode = @"待审核";
                     [w renderContent];
                 }];
    [self addButton:@"查看活动审核状态"
              style:@"outline"
             action:^{
                 [w pushRoute:@"activityReview" identifier:w.objectId];
             }];
    [self addButton:@"活动公告与问答"
              style:@"outline"
             action:^{
                 [w pushRoute:@"notice" identifier:w.objectId];
             }];
    if (![a[@"cancelled"] boolValue])
        [self addButton:@"取消本次约行"
                  style:@"danger"
                 action:^{
                     UIAlertController *alert = [UIAlertController
                         alertControllerWithTitle:@"取消本次约行"
                                          message:@"请填写取消原因。报名将关闭，保留系统消息。"
                                   preferredStyle:UIAlertControllerStyleAlert];
                     [alert addTextFieldWithConfigurationHandler:^(UITextField *f) {
                         f.placeholder = @"例如：天气不适合出行";
                     }];
                     [alert addAction:[UIAlertAction actionWithTitle:@"暂不操作"
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil]];
                     __weak UIAlertController *wa = alert;
                     [alert addAction:[UIAlertAction
                                          actionWithTitle:@"确认取消"
                                                    style:UIAlertActionStyleDestructive
                                                  handler:^(UIAlertAction *act) {
                                                      NSString *reason = wa.textFields.firstObject.text;
                                                      if (!reason.length)
                                                          reason = @"发起人取消活动";
                                                      [w.store cancelActivity:w.objectId reason:reason];
                                                      [w renderContent];
                                                  }]];
                     [w presentViewController:alert animated:YES completion:nil];
                 }];
}
@end
