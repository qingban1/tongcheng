#import "TYReflectionViewController.h"
@implementation TYReflectionViewController
- (void)viewDidLoad {
    NSDictionary *t = [self.store item:self.objectId in:@"trips"];
    self.values = t[@"reflection"] ? [t[@"reflection"] mutableCopy] : [NSMutableDictionary new];
    [super viewDidLoad];
}
- (void)renderContent {
    [super renderContent];
    [self addBackTitle:@"一分钟复盘"];
    [self add:[TYDesign label:@"今天的经验，\n留给下次的自己。" size:28 weight:UIFontWeightBold]];
    [self addChoice:@"这次体感如何" key:@"effort" options:@[ @"轻松", @"适中", @"吃力" ] initial:@"适中"];
    [self addChoice:@"这次节奏如何" key:@"pace" options:@[ @"偏慢", @"合适", @"偏快" ] initial:@"合适"];
    [self addTextArea:@"装备经验" key:@"gear" initial:nil limit:300];
    [self addTextArea:@"给下次的一句提醒" key:@"tip" initial:nil limit:200];
    __weak typeof(self) w = self;
    [self addButton:@"保存私人复盘"
              style:@""
             action:^{
                 NSMutableDictionary *t = [w.store item:w.objectId in:@"trips"];
                 if (!t)
                     return;
                 t[@"reflection"] = [w.values mutableCopy];
                 [w.store commit];
                 [w.navigationController popViewControllerAnimated:YES];
             }];
    [self addNote:@"复盘默认私密，分享时需要另行选择公开心得。"];
}
@end
