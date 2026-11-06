#import "TYNoticeViewController.h"
@implementation TYNoticeViewController
- (void)renderContent {
    [super renderContent];
    [self addBackTitle:@"活动公告与问答"];
    [self addNote:@"公告与问答仅保存在本设备，不会发送给发起人或其他用户。"];
    NSDictionary *a = [self.store item:self.objectId in:@"activities"];
    if (!a || ![self.store canAccessActivity:a]) {
        [self addNote:@"通过报名后开放。你现在无法查看集合详情和成员问答。"];
        return;
    }
    BOOL own = [a[@"author"] isEqual:@"self"], cancelled = [a[@"cancelled"] boolValue];
    __weak typeof(self) w = self;
    [self add:[TYDesign card:@[
              [TYDesign label:a[@"title"] size:20 weight:UIFontWeightSemibold],
              [TYDesign label:[NSString stringWithFormat:@"%@ · %@", a[@"location"],
                                                         [TYLocalStore dateText:a[@"date"]]]
                         size:13
                       weight:UIFontWeightRegular]
          ]
                        dark:YES]];
    [self addNote:cancelled ? @"活动已取消，请勿按原计划集合。" : @"出发前请核对集合时间和现场开放情况。"];
    for (NSDictionary *n in [self.store items:@"notices"])
        if ([n[@"activityId"] isEqual:self.objectId])
            [self add:[TYDesign card:@[
                      [TYDesign label:@"发起人公告" size:18 weight:UIFontWeightSemibold],
                      [TYDesign label:n[@"text"] size:14 weight:UIFontWeightRegular]
                  ]
                                dark:NO]];
    if (own && !cancelled) {
        [self addTextArea:@"公告内容" key:@"notice" initial:@"" limit:500];
        [self addButton:@"发布活动公告"
                  style:@""
                 action:^{
                     if (![w validateRequired:@[ @"notice" ]])
                         return;
                     [w.store.state[@"notices"] insertObject:[@{
                                                    @"id" : TYLocalStore.identifier,
                                                    @"activityId" : w.objectId,
                                                    @"text" : w.values[@"notice"]
                                                } mutableCopy]
                                                     atIndex:0];
                     [w.values removeObjectForKey:@"notice"];
                     [w.store addMessage:@"活动公告已更新。"
                                    type:@"活动"
                                   route:@"notice"
                                objectId:w.objectId];
                     [w.store commit];
                     [w renderContent];
                 }];
    }
    [self addSection:@"成员问答"];
    for (NSMutableDictionary *q in [self.store items:@"questions"]) {
        if (![q[@"activityId"] isEqual:self.objectId])
            continue;
        NSMutableArray *views = [NSMutableArray arrayWithArray:@[
            [TYDesign pill:q[@"type"]], [TYDesign label:q[@"text"] size:14 weight:UIFontWeightRegular],
            [TYDesign label:q[@"answer"] ?: @"等待发起人回复" size:12 weight:UIFontWeightRegular]
        ]];
        if (own && !q[@"answer"]) {
            [views addObject:[TYDesign
                                 button:@"回复问题"
                                  style:@"outline"
                                 action:^{
                                     UIAlertController *al = [UIAlertController
                                         alertControllerWithTitle:@"回复问题"
                                                          message:q[@"text"]
                                                   preferredStyle:UIAlertControllerStyleAlert];
                                     [al addTextFieldWithConfigurationHandler:nil];
                                     __weak UIAlertController *wa = al;
                                     [al addAction:[UIAlertAction actionWithTitle:@"取消"
                                                                            style:UIAlertActionStyleCancel
                                                                          handler:nil]];
                                     [al addAction:[UIAlertAction
                                                       actionWithTitle:@"保存回复"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction *action) {
                                                                   NSString *text =
                                                                       wa.textFields.firstObject.text;
                                                                   if (text.length) {
                                                                       q[@"answer"] = [text
                                                                           substringToIndex:MIN(200,
                                                                                                text.length)];
                                                                       [w.store commit];
                                                                       [w renderContent];
                                                                   }
                                                               }]];
                                     [w presentViewController:al animated:YES completion:nil];
                                 }]];
        }
        [self add:[TYDesign card:views dark:NO]];
    }
    if (!cancelled) {
        [self addChoice:@"问题类别"
                    key:@"type"
                options:@[ @"集合", @"时间", @"装备", @"节奏" ]
                initial:@"集合"];
        [self addTextArea:@"活动问题" key:@"question" initial:@"" limit:200];
        [self addButton:@"提交问题"
                  style:@""
                 action:^{
                     if (![w validateRequired:@[ @"question" ]])
                         return;
                     [w.store.state[@"questions"] insertObject:[@{
                                                      @"id" : TYLocalStore.identifier,
                                                      @"activityId" : w.objectId,
                                                      @"type" : w.values[@"type"],
                                                      @"text" : w.values[@"question"]
                                                  } mutableCopy]
                                                       atIndex:0];
                     [w.values removeObjectForKey:@"question"];
                     [w.store commit];
                     [w renderContent];
                 }];
    }
}
@end
