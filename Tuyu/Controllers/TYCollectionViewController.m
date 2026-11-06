#import "TYCollectionViewController.h"
#import "TYCards.h"
@implementation TYCollectionViewController
- (void)viewDidLoad {
    NSDictionary *c = [self.store item:self.objectId in:@"collections"];
    self.values = c ? [c mutableCopy]
                    : [@{@"title" : @"", @"tripIds" : [NSMutableArray new], @"public" : @NO} mutableCopy];
    self.values[@"tripIds"] = [self.values[@"tripIds"] mutableCopy];
    [super viewDidLoad];
}
- (void)renderContent {
    [super renderContent];
    BOOL edit = [self.screenMode isEqual:@"edit"];
    [self addBackTitle:edit ? @"编辑主题合集" : @"主题合集"];
    __weak typeof(self) w = self;
    if (edit) {
        [self addField:@"合集名称" key:@"title" initial:nil numeric:NO limit:20];
        [self addSection:@"选择行程"];
        for (NSDictionary *t in [self.store items:@"trips"]) {
            NSString *identifier = t[@"id"];
            BOOL selected = [self.values[@"tripIds"] containsObject:identifier];
            [self addButton:[NSString stringWithFormat:@"%@ %@", selected ? @"✓" : @"＋", t[@"title"]]
                      style:selected ? @"" : @"outline"
                     action:^{
                         NSMutableArray *a = w.values[@"tripIds"];
                         if ([a containsObject:identifier])
                             [a removeObject:identifier];
                         else
                             [a addObject:identifier];
                         [w renderContent];
                     }];
        }
        [self addSwitch:@"公开合集标题、封面与条目数量" key:@"public" initial:NO];
        [self addButton:@"保存主题合集"
                  style:@""
                 action:^{
                     if (![w validateRequired:@[ @"title" ]])
                         return;
                     if ([w.values[@"public"] boolValue] && ![w.values[@"tripIds"] count]) {
                         [w showMessage:@"空合集不能公开，请添加行程或关闭公开选项。"];
                         return;
                     }
                     NSMutableDictionary *c = [w.store item:w.objectId in:@"collections"];
                     if (!c) {
                         c = [NSMutableDictionary new];
                         c[@"id"] = TYLocalStore.identifier;
                         [w.store.state[@"collections"] addObject:c];
                         w.objectId = c[@"id"];
                     }
                     [c addEntriesFromDictionary:w.values];
                     [w.store commit];
                     w.screenMode = nil;
                     [w renderContent];
                 }];
        [self addNote:@"公开摘要仅包含合集标题、封面和条目数量，不公开私人轨迹与复盘。"];
        return;
    }
    NSDictionary *c = [self.store item:self.objectId in:@"collections"];
    if (!c) {
        [self addNote:@"还没有主题合集。"];
        [self addButton:@"创建主题合集"
                  style:@"outline"
                 action:^{
                     w.screenMode = @"edit";
                     [w renderContent];
                 }];
        return;
    }
    [self add:[TYDesign hero:@"forest"
                       title:c[@"title"]
                    subtitle:[c[@"public"] boolValue] ? @"公开摘要 · 原始行程仍私密" : @"私人合集"
                       badge:@"主题收藏"]];
    for (NSString *identifier in c[@"tripIds"]) {
        NSDictionary *t = [self.store item:identifier in:@"trips"];
        if (t)
            [self add:[TYCards trip:t
                             action:^{
                                 [w pushRoute:@"journal" identifier:identifier];
                             }]];
    }
    [self addButton:@"编辑主题合集"
              style:@"outline"
             action:^{
                 w.screenMode = @"edit";
                 [w renderContent];
             }];
    [self addButton:@"删除主题合集"
              style:@"danger"
             action:^{
                 [w confirm:@"确认删除合集"
                       text:@"不删除其中的原始行程。"
                     action:^{
                         NSMutableDictionary *v = [w.store item:w.objectId in:@"collections"];
                         [w.store.state[@"collections"] removeObject:v];
                         [w.store commit];
                         [w.navigationController popViewControllerAnimated:YES];
                     }];
             }];
}
@end
