#import "TYPostViewController.h"
#import "TYCards.h"
@implementation TYPostViewController
- (void)renderContent {
    [super renderContent];
    [self addBackTitle:[self.screenMode isEqual:@"author"] ? @"作者主页" : @"作品详情"];
    [self addNote:@"内置人物和互动仅供本机演示。"];
    NSDictionary *p = [self.store item:self.objectId in:@"posts"];
    if (!p) {
        [self addNote:@"作品已不存在或被删除。"];
        return;
    }
    NSString *author = p[@"author"];
    BOOL own = [author isEqual:@"self"];
    __weak typeof(self) w = self;
    if ([self.store containsIdentifier:author in:@"blocked"]) {
        [self addNote:@"该用户已被屏蔽，解除后可再次查看。"];
        [self addButton:@"管理屏蔽名单"
                  style:@"outline"
                 action:^{
                     [w pushRoute:@"blocked" identifier:nil];
                 }];
        return;
    }
    if ([self.screenMode isEqual:@"author"]) {
        [self add:[TYDesign person:p[@"name"]
                          subtitle:own ? self.store.state[@"profile"][@"bio"]
                                       : @"以自己的节奏，收集每个周末的山野来信。"]];
        [self followButton:author];
        [self addSection:@"公开作品"];
        for (NSDictionary *post in [self.store items:@"posts"])
            if ([post[@"author"] isEqual:author] && [post[@"status"] isEqual:@"public"]) {
                NSString *identifier = post[@"id"];
                [self add:[TYCards post:post
                                 action:^{
                                     [w pushRoute:@"post" identifier:identifier];
                                 }]];
            }
        return;
    }
    [self add:[TYCards tappable:[TYDesign person:p[@"name"] subtitle:@"山友主页"]
                          label:@"查看作者主页"
                         action:^{
                             [w pushRoute:@"author" identifier:w.objectId];
                         }]];
    [self add:[TYDesign hero:p[@"photo"]
                       title:p[@"title"]
                    subtitle:@"照片仅作山野氛围展示"
                       badge:p[@"template"] ?: @"照片故事"]];
    [self addText:p[@"body"] ?: @""];
    if (p[@"seconds"]) {
        NSMutableDictionary *metric = [@{
            @"seconds" : p[@"seconds"],
            @"mode" : p[@"distance"] ? @"轨迹" : @"仅计时",
            @"sample" : p[@"sample"] ?: @NO
        } mutableCopy];
        if (p[@"distance"])
            metric[@"distance"] = p[@"distance"];
        [self add:[TYDesign metrics:metric]];
    }
    if ([p[@"tip"] length])
        [self add:[TYDesign card:@[
                  [TYDesign label:@"留给下次的一句话" size:11 weight:UIFontWeightRegular],
                  [TYDesign label:p[@"tip"] size:14 weight:UIFontWeightRegular]
              ]
                            dark:YES]];
    [self addNote:@"精确轨迹、起终点和照片定位不公开。"];
    if (own) {
        [self addButton:@"查看作品审核状态"
                  style:@"outline"
                 action:^{
                     [w pushRoute:@"postReview" identifier:w.objectId];
                 }];
        [self addButton:@"删除这篇作品"
                  style:@"danger"
                 action:^{
                     [w confirm:@"删除这篇作品"
                           text:@"只删除作品，不影响原始行程。"
                         action:^{
                             NSMutableDictionary *post = [w.store item:w.objectId in:@"posts"];
                             [w.store.state[@"posts"] removeObject:post];
                             [w.store commit];
                             [w.navigationController popViewControllerAnimated:YES];
                         }];
                 }];
    } else {
        NSString *liked = [self.store containsIdentifier:self.objectId in:@"liked"] ? @"已喜欢" : @"喜欢",
                 *saved = [self.store containsIdentifier:self.objectId in:@"saved"] ? @"已收藏" : @"收藏";
        [self add:[TYDesign horizontalStack:@[
                  [TYDesign button:liked
                             style:@"outline"
                            action:^{
                                [w.store toggleIdentifier:w.objectId in:@"liked"];
                                [w renderContent];
                            }],
                  [TYDesign button:saved
                             style:@"outline"
                            action:^{
                                [w.store toggleIdentifier:w.objectId in:@"saved"];
                                [w renderContent];
                            }]
              ]]];
        [self followButton:author];
        [self addButton:@"举报与屏蔽"
                  style:@"outline"
                 action:^{
                     [w pushRoute:@"report" identifier:w.objectId];
                 }];
    }
}
- (void)followButton:(NSString *)author {
    if ([author isEqual:@"self"])
        return;
    __weak typeof(self) w = self;
    [self addButton:[self.store containsIdentifier:author in:@"following"] ? @"已关注作者" : @"关注作者"
              style:@""
             action:^{
                 [w.store toggleIdentifier:author in:@"following"];
                 [w renderContent];
             }];
}
@end
