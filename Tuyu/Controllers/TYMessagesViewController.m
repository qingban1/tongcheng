#import "TYMessagesViewController.h"
@implementation TYMessagesViewController
- (void)renderContent {
    [super renderContent];
    self.screenMode = self.screenMode ?: @"活动";
    [self addBackTitle:@"消息中心"];
    __weak typeof(self) w = self;
    [self addChips:@[ @"活动", @"互动", @"系统" ]
          selected:self.screenMode
            action:^(NSString *t) {
                w.screenMode = t;
                [w renderContent];
            }];
    NSInteger count = 0;
    for (NSMutableDictionary *m in [self.store items:@"messages"]) {
        if (![m[@"type"] isEqual:self.screenMode])
            continue;
        [self add:[TYDesign card:@[
                  [TYDesign pill:[m[@"read"] boolValue] ? @"已读" : @"未读"],
                  [TYDesign label:m[@"text"] size:14 weight:UIFontWeightRegular],
                  [TYDesign button:@"查看详情"
                             style:@"outline"
                            action:^{
                                m[@"read"] = @YES;
                                [w.store commit];
                                [w pushRoute:m[@"route"] identifier:m[@"objectId"]];
                            }]
              ]
                            dark:NO]];
        count++;
    }
    if (!count)
        [self addNote:@"当前没有消息。报名、作品审核等操作会生成站内消息。"];
    [self addButton:@"全部标记为已读"
              style:@"outline"
             action:^{
                 for (NSMutableDictionary *m in [w.store items:@"messages"])
                     m[@"read"] = @YES;
                 [w.store commit];
                 [w renderContent];
             }];
}
@end
