#import "TYJournalViewController.h"
@implementation TYJournalViewController
- (void)renderContent {
    [super renderContent];
    [self addBackTitle:[self.screenMode isEqual:@"summary"] ? @"完成总结" : @"行程详情"];
    NSMutableDictionary *t = [self.store item:self.objectId in:@"trips"];
    if (!t) {
        [self addNote:@"行程已不存在。"];
        return;
    }
    __weak typeof(self) w = self;
    if ([self.screenMode isEqual:@"summary"]) {
        [self add:[TYDesign label:@"走过的路，\n成为你的故事。" size:28 weight:UIFontWeightBold]];
        [self add:[TYDesign metrics:t]];
        [self addNote:@"已加入记录、月历与徒步护照。可以先复盘，再分享。"];
        [self addButton:@"一分钟复盘"
                  style:@""
                 action:^{
                     [w pushRoute:@"reflection" identifier:w.objectId];
                 }];
        [self addButton:@"生成山野分享卡"
                  style:@"outline"
                 action:^{
                     [w pushRoute:@"share" identifier:w.objectId];
                 }];
        [self addButton:@"查看本次行程"
                  style:@"outline"
                 action:^{
                     [w pushRoute:@"journal" identifier:w.objectId];
                 }];
        return;
    }
    [self add:[TYDesign pill:[t[@"sample"] boolValue] ? @"示例行程 · 私密" : @"本机行程 · 私密"]];
    [self add:[TYDesign label:t[@"title"] size:28 weight:UIFontWeightBold]];
    [self addText:[TYLocalStore dateText:t[@"start"]]];
    if (t[@"distance"])
        [self add:[TYDesign mapWithPoints:t[@"points"] example:[t[@"sample"] boolValue]]];
    else
        [self addNote:@"本次为仅计时记录，没有采集距离、轨迹或位置。"];
    [self add:[TYDesign metrics:t]];
    [self addSection:@"沿途的片刻"];
    if ([t[@"markers"] count]) {
        for (NSDictionary *m in t[@"markers"]) {
            [self add:[TYDesign pill:m[@"type"]]];
            [self addText:m[@"text"]];
            if (m[@"photo"])
                [self add:[TYDesign photo:m[@"photo"] height:200]];
        }
    } else if ([t[@"sample"] boolValue])
        [self add:[TYDesign photo:t[@"photo"] height:180]];
    else
        [self addNote:@"本次没有添加沿途标记。"];
    [self addSection:@"留给下次的经验"];
    NSDictionary *r = t[@"reflection"];
    if (r)
        [self add:[TYDesign card:@[
                  [TYDesign pill:[NSString stringWithFormat:@"%@ · %@", r[@"effort"], r[@"pace"]]],
                  [TYDesign label:r[@"tip"] ?: @"未填写提醒" size:14 weight:UIFontWeightRegular],
                  [TYDesign label:[@"装备经验：" stringByAppendingString:r[@"gear"] ?: @""]
                             size:12
                           weight:UIFontWeightRegular]
              ]
                            dark:YES]];
    else
        [self addNote:@"还没有复盘，可以用一分钟留下经验。"];
    [self addButton:@"编辑私人复盘"
              style:@"outline"
             action:^{
                 [w pushRoute:@"reflection" identifier:w.objectId];
             }];
    [self addButton:@"生成山野分享卡"
              style:@""
             action:^{
                 [w pushRoute:@"share" identifier:w.objectId];
             }];
    [self addButton:@"修改行程标题"
              style:@"outline"
             action:^{
                 UIAlertController *a =
                     [UIAlertController alertControllerWithTitle:@"行程标题"
                                                         message:@"最多30个字"
                                                  preferredStyle:UIAlertControllerStyleAlert];
                 [a addTextFieldWithConfigurationHandler:^(UITextField *f) {
                     f.text = t[@"title"];
                 }];
                 __weak UIAlertController *wa = a;
                 [a addAction:[UIAlertAction actionWithTitle:@"取消"
                                                       style:UIAlertActionStyleCancel
                                                     handler:nil]];
                 [a addAction:[UIAlertAction
                                  actionWithTitle:@"保存行程标题"
                                            style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction *act) {
                                              NSString *name = [wa.textFields.firstObject.text
                                                  stringByTrimmingCharactersInSet:
                                                      NSCharacterSet.whitespaceAndNewlineCharacterSet];
                                              if (name.length) {
                                                  t[@"title"] = [name substringToIndex:MIN(name.length, 30)];
                                                  [w.store commit];
                                                  [w renderContent];
                                              }
                                          }]];
                 [w presentViewController:a animated:YES completion:nil];
             }];
    [self addButton:@"删除本条行程"
              style:@"danger"
             action:^{
                 [w confirm:@"确认删除行程"
                       text:@"同步更新统计、月历与合集，作品保留已确认公开的快照。"
                     action:^{
                         [w.store deleteTrip:w.objectId];
                         [w.navigationController popViewControllerAnimated:YES];
                     }];
             }];
}
@end
