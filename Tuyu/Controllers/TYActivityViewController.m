#import "TYActivityViewController.h"
@implementation TYActivityViewController
- (void)renderContent {
    [super renderContent];
    __weak typeof(self) w = self;
    NSMutableDictionary *a = [self.store item:self.objectId in:@"activities"];
    [self addBackTitle:@"活动详情"];
    [self addNote:@"内置活动或本机草稿，仅用于演示。集合信息不代表真实活动安排。"];
    if (!a) {
        [self addNote:@"活动已不存在。"];
        return;
    }
    [self add:[TYDesign hero:a[@"photo"]
                       title:a[@"title"]
                    subtitle:[NSString stringWithFormat:@"%@ · %@", a[@"city"], a[@"area"]]
                       badge:a[@"pace"]]];
    [self add:[TYDesign pill:[self.store statusForActivity:a]]];
    [self addNote:@"摄影示意 · 发起人提供路线信息"];
    [self add:[TYDesign card:@[
              [TYDesign label:[TYLocalStore dateText:a[@"date"]] size:18 weight:UIFontWeightSemibold],
              [TYDesign label:[NSString stringWithFormat:@"预计结束 %@\n报名截止 %@",
                                                         [TYLocalStore dateText:a[@"end"]],
                                                         [TYLocalStore dateText:a[@"deadline"]]]
                         size:12
                       weight:UIFontWeightRegular],
              [TYDesign label:[NSString stringWithFormat:@"%@ km    爬升 %@ m    %@/%@人", a[@"distance"],
                                                         a[@"climb"], a[@"joined"], a[@"capacity"]]
                         size:18
                       weight:UIFontWeightSemibold]
          ]
                        dark:NO]];
    [self add:[TYDesign person:a[@"host"] subtitle:@"发起人"]];
    [self addSection:@"这次怎么走"];
    [self addText:a[@"description"]];
    [self addSection:@"集合与准备"];
    [self
        addNote:[NSString stringWithFormat:@"%@ · %@\n%@", a[@"city"], a[@"area"],
                                           [self.store canAccessActivity:a] ? a[@"location"]
                                                                            : @"通过报名后可查看详细集合点"]];
    [self addText:a[@"gear"]];
    if ([self.store canAccessActivity:a])
        [self addButton:@"查看活动公告与问答"
                  style:@"outline"
                 action:^{
                     [w pushRoute:@"notice" identifier:w.objectId];
                 }];
    BOOL mine = [a[@"author"] isEqual:@"self"];
    NSString *s = [self.store applicationStatus:self.objectId];
    if (mine) {
        [self addButton:@"管理我的约行"
                  style:@""
                 action:^{
                     [w pushRoute:@"participants" identifier:w.objectId];
                 }];
        return;
    }
    if ([s isEqual:@"pending"]) {
        [self addNote:@"申请已提交，等待发起人审核。"];
        [self addButton:@"撤回报名申请"
                  style:@"outline"
                 action:^{
                     [w leave];
                 }];
        [self addButton:@"演示审核结果"
                  style:@""
                 action:^{
                     [w confirm:@"模拟通过报名"
                           text:@"只改变本机演示状态，不代表真实发起人审核。"
                         action:^{
                             NSError *e;
                             if ([w.store setApplication:w.objectId status:@"approved" error:&e])
                                 [w renderContent];
                             else
                                 [w showError:e];
                         }];
                 }];
        [self addButton:@"演示报名未通过"
                  style:@"outline"
                 action:^{
                     NSError *e;
                     [w.store setApplication:w.objectId status:@"rejected" error:&e];
                     [w renderContent];
                 }];
    } else if ([s isEqual:@"approved"]) {
        [self addNote:@"报名已通过。请在出发前核对集合信息。"];
        [self addButton:@"关联并开始徒步"
                  style:@""
                 action:^{
                     w.store.state[@"linkedActivityId"] = w.objectId;
                     [w.store commit];
                     [w selectTab:3];
                 }];
        [self addButton:@"退出本次约行"
                  style:@"outline"
                 action:^{
                     [w leave];
                 }];
    } else if ([s isEqual:@"rejected"]) {
        [self addNote:@"本次申请未通过，不能重复申请。"];
    } else {
        BOOL enabled = [[self.store statusForActivity:a] isEqual:@"招募中"] &&
                       ![self.store containsIdentifier:a[@"author"] in:@"blocked"];
        TYActionButton *b = [TYDesign button:enabled ? @"申请同行" : [self.store statusForActivity:a]
                                       style:@""
                                      action:^{
                                          [w pushRoute:@"apply" identifier:w.objectId];
                                      }];
        b.enabled = enabled;
        [self add:b];
    }
    [self addNote:@"免费自愿结伴。距离与用时为估算，请根据自身情况选择。"];
}
- (void)leave {
    __weak typeof(self) w = self;
    [self confirm:@"退出或撤回申请"
             text:@"已确认名额会释放，集合详情和问答访问将关闭。"
           action:^{
               NSError *e;
               if ([w.store setApplication:w.objectId status:@"none" error:&e])
                   [w renderContent];
               else
                   [w showError:e];
           }];
}
@end
