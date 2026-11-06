#import "TYFeedbackViewController.h"
#import "TYTrackingService.h"
#import "TYArtwork.h"
@implementation TYFeedbackViewController
- (void)renderContent {
    [super renderContent];
    NSString *mode = self.screenMode ?: @"privacy";
    __weak typeof(self) w = self;

    BOOL report = [mode isEqual:@"report"];
    [self addBackTitle:report ? @"举报与屏蔽" : @"帮助与反馈"];
    [self add:[TYDesign label:report ? @"让相遇，多一点尊重。" : @"把问题告诉我们。"
                         size:28
                       weight:UIFontWeightBold]];
    [self addChoice:report ? @"举报原因" : @"问题类型"
                key:@"type"
            options:report ? @[ @"不当内容", @"虚假活动", @"骚扰", @"隐私泄露", @"其他" ]
                           : @[ @"功能问题", @"约行问题", @"内容投诉", @"建议" ]
            initial:report ? @"不当内容" : @"功能问题"];
    [self addTextArea:report ? @"补充说明" : @"具体说明" key:@"text" initial:nil limit:report ? 500 : 1000];
    [self
        addButton:report ? @"保存举报回执" : @"保存反馈回执"
            style:@""
           action:^{
               if (!report && ![w validateRequired:@[ @"text" ]])
                   return;
               NSMutableDictionary *receipt = [w.values mutableCopy];
               receipt[@"id"] = TYLocalStore.identifier;
               if (w.objectId)
                   receipt[@"objectId"] = w.objectId;
               [w.store.state[report ? @"reports" : @"feedback"] insertObject:receipt atIndex:0];
               [w.store commit];
               [w showMessage:[NSString stringWithFormat:@"本机回执已保存：%@\n未向实际客服或审核人员发送。",
                                                         receipt[@"id"]]];
           }];
    if (report) {
        [self addButton:@"屏蔽此用户"
                  style:@"outline"
                 action:^{
                     NSDictionary *p = [w.store item:w.objectId in:@"posts"];
                     NSString *author = p[@"author"];
                     if (!author || [author isEqual:@"self"]) {
                         [w showMessage:@"不能屏蔽自己。"];
                         return;
                     }
                     if (![w.store containsIdentifier:author in:@"blocked"])
                         [w.store toggleIdentifier:author in:@"blocked"];
                     [w pushRoute:@"blocked" identifier:nil];
                 }];
    }
    [self addNote:@"数据仅保存在本机。正式社区需要真实后台、开发者联系方式与持续审核运营。"];
    return;
}
@end
