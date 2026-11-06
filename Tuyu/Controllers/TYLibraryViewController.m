#import "TYLibraryViewController.h"
#import "TYCards.h"
@interface TYLibraryViewController ()
@property(nonatomic, copy) NSString *selectedGroup;
@end
@implementation TYLibraryViewController
- (void)renderContent {
    [super renderContent];
    __weak typeof(self) w = self;
    NSString *mode = self.screenMode ?: @"works";
    if ([mode isEqual:@"blocked"]) {
        [self addBackTitle:@"屏蔽名单"];
        NSArray *blocked = self.store.state[@"blocked"];
        for (NSString *author in blocked) {
            NSString *name =
                [author isEqual:@"cheng"] ? @"山野阿橙" : ([author isEqual:@"he"] ? @"阿禾" : @"阿岳");
            [self add:[TYDesign card:@[
                      [TYDesign person:name subtitle:@"已屏蔽"],
                      [TYDesign button:@"解除屏蔽"
                                 style:@"outline"
                                action:^{
                                    [w.store toggleIdentifier:author in:@"blocked"];
                                    [w renderContent];
                                }]
                  ]
                                dark:NO]];
        }
        if (!blocked.count)
            [self addNote:@"暂无屏蔽用户。"];
        return;
    }
    if ([mode isEqual:@"reviews"]) {
        [self addBackTitle:@"复盘档案"];
        [self add:[TYDesign label:@"下次出发，记得这些。" size:28 weight:UIFontWeightBold]];
        NSInteger count = 0;
        for (NSDictionary *t in [self.store items:@"trips"]) {
            NSDictionary *r = t[@"reflection"];
            if (!r)
                continue;
            NSString *identifier = t[@"id"];
            [self add:[TYDesign card:@[
                      [TYDesign label:t[@"title"] size:13 weight:UIFontWeightRegular],
                      [TYDesign label:[NSString stringWithFormat:@"%@ · %@", r[@"effort"], r[@"pace"]]
                                 size:18
                               weight:UIFontWeightSemibold],
                      [TYDesign label:r[@"tip"] ?: @"未填写提醒" size:14 weight:UIFontWeightRegular],
                      [TYDesign button:@"查看或编辑复盘"
                                 style:@"gradient"
                                action:^{
                                    [w pushRoute:@"reflection" identifier:identifier];
                                }]
                  ]
                                dark:YES]];
            count++;
        }
        if (!count)
            [self addNote:@"还没有保存复盘。"];
        return;
    }
    BOOL favorites = [mode isEqual:@"favorites"];
    [self addBackTitle:favorites ? @"我的收藏" : @"我的作品"];
    if (!favorites) {
        self.selectedGroup = self.selectedGroup ?: @"全部";
        [self addChips:@[ @"全部", @"审核中", @"已公开", @"未通过", @"已下架", @"草稿" ]
              selected:self.selectedGroup
                action:^(NSString *t) {
                    w.selectedGroup = t;
                    [w renderContent];
                }];
        if ([self.selectedGroup isEqual:@"草稿"]) {
            NSDictionary *d = self.store.state[@"draft"];
            [self addNote:d ? ([d[@"title"] length] ? d[@"title"] : @"未命名草稿") : @"暂无分享草稿。"];
            if (d)
                [self addButton:@"继续编辑草稿"
                          style:@"outline"
                         action:^{
                             [w pushRoute:@"share" identifier:nil];
                         }];
            return;
        }
    }
    NSInteger count = 0;
    NSString *s =
        @{@"审核中" : @"pending",
          @"已公开" : @"public",
          @"未通过" : @"rejected",
          @"已下架" : @"removed"}[self.selectedGroup ?: @""];
    for (NSDictionary *p in [self.store items:@"posts"]) {
        if (favorites) {
            if (![self.store containsIdentifier:p[@"id"] in:@"saved"] || ![p[@"status"] isEqual:@"public"] ||
                [self.store containsIdentifier:p[@"author"] in:@"blocked"])
                continue;
        } else if (![p[@"author"] isEqual:@"self"] || (s && ![p[@"status"] isEqual:s]))
            continue;
        NSString *identifier = p[@"id"];
        [self add:[TYCards post:p
                         action:^{
                             [w pushRoute:@"post" identifier:identifier];
                         }]];
        count++;
    }
    if (!count)
        [self addNote:favorites ? @"看到喜欢的作品，点击收藏就能在这里找到。" : @"当前分组没有作品。"];
    if (!favorites)
        [self addButton:@"制作新作品"
                  style:@""
                 action:^{
                     [w pushRoute:@"share" identifier:nil];
                 }];
}
@end
