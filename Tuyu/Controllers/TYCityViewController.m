#import "TYCityViewController.h"
@implementation TYCityViewController
- (void)renderContent {
    [super renderContent];
    [self addBackTitle:@"城市选择"];
    [self add:[TYDesign label:@"这次，在哪里相遇？" size:28 weight:UIFontWeightBold]];
    [self addNote:@"手动选择即可，不需要定位权限。"];
    [self addField:@"城市名称" key:@"city" initial:self.store.state[@"city"] numeric:NO limit:20];
    __weak typeof(self) w = self;
    [self addButton:@"确认城市"
              style:@""
             action:^{
                 if (![w validateRequired:@[ @"city" ]])
                     return;
                 w.store.state[@"city"] = w.values[@"city"];
                 [w.store commit];
                 [w.navigationController popViewControllerAnimated:YES];
             }];
    [self addSection:@"常用城市"];
    [self addChips:@[ @"杭州", @"上海", @"南京", @"成都", @"深圳", @"北京" ]
          selected:self.store.state[@"city"]
            action:^(NSString *t) {
                w.store.state[@"city"] = t;
                [w.store commit];
                [w.navigationController popViewControllerAnimated:YES];
            }];
}
@end
