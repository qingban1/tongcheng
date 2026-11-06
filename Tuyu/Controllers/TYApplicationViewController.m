#import "TYApplicationViewController.h"
@implementation TYApplicationViewController
- (void)renderContent {
    [super renderContent];
    [self addBackTitle:@"报名申请"];
    NSDictionary *a = [self.store item:self.objectId in:@"activities"];
    if (!a) {
        [self addNote:@"活动已不存在。"];
        return;
    }
    [self add:[TYDesign label:@"一起走，\n也要节奏相近。" size:28 weight:UIFontWeightBold]];
    [self addNote:a[@"title"]];
    [self addChoice:@"你的徒步经验"
                key:@"experience"
            options:@[ @"初次尝试", @"偶尔徒步", @"经常徒步" ]
            initial:@"偶尔徒步"];
    [self addChoice:@"你喜欢的节奏"
                key:@"pace"
            options:@[ @"轻松慢走", @"边走边拍", @"稳定行进" ]
            initial:self.store.state[@"profile"][@"pace"]];
    [self addTextArea:@"给发起人的一句话" key:@"intro" initial:@"" limit:200];
    [self addSwitch:@"我已年满18岁，已了解活动信息与社区规范。" key:@"adult" initial:NO];
    __weak typeof(self) w = self;
    [self addButton:@"提交同行申请"
              style:@""
             action:^{
                 if (![w.values[@"adult"] boolValue]) {
                     [w showMessage:@"请先确认成人与社区规范声明。"];
                     return;
                 }
                 NSError *e;
                 if ([w.store applyToActivity:w.objectId values:w.values error:&e]) {
                     [w pushRoute:@"applicationResult" identifier:w.objectId];
                 } else
                     [w showError:e];
             }];
    [self addNote:@"提交申请不占名额，通过后才计入人数。"];
}
@end
