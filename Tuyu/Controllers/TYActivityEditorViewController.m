#import "TYActivityEditorViewController.h"
@implementation TYActivityEditorViewController
- (void)viewDidLoad {
    NSDictionary *initial =
        self.objectId ? [self.store item:self.objectId in:@"activities"] : self.store.state[@"activityDraft"];
    self.values = initial ? [initial mutableCopy] : [NSMutableDictionary new];
    [super viewDidLoad];
}
- (void)renderContent {
    [super renderContent];
    [self addBackTitle:@"发布活动"];
    [self add:[TYDesign label:@"发出你的\n山野邀请。" size:28 weight:UIFontWeightBold]];
    [self addField:@"活动标题" key:@"title" initial:nil numeric:NO limit:30];
    [self addField:@"路线名称" key:@"route" initial:nil numeric:NO limit:30];
    [self addField:@"城市" key:@"city" initial:self.store.state[@"city"] numeric:NO limit:20];
    [self addDate:@"开始时间" key:@"date" initial:@(NSDate.date.timeIntervalSince1970 + 3 * 86400)];
    [self addDate:@"预计结束时间"
              key:@"end"
          initial:@(NSDate.date.timeIntervalSince1970 + 3 * 86400 + 14400)];
    [self addDate:@"报名截止时间" key:@"deadline" initial:@(NSDate.date.timeIntervalSince1970 + 2 * 86400)];
    [self addField:@"预计距离 km" key:@"distance" initial:@"" numeric:YES limit:6];
    [self addField:@"预计爬升 m" key:@"climb" initial:@"" numeric:YES limit:5];
    [self addField:@"人数上限 含本人" key:@"capacity" initial:@6 numeric:YES limit:2];
    [self addChoice:@"活动节奏"
                key:@"pace"
            options:@[ @"轻松慢走", @"边走边拍", @"稳定行进" ]
            initial:@"边走边拍"];
    [self addField:@"集合区域 公开" key:@"area" initial:nil numeric:NO limit:50];
    [self addField:@"详细集合点 仅通过成员可见" key:@"location" initial:nil numeric:NO limit:100];
    [self addTextArea:@"路线与路面说明" key:@"description" initial:nil limit:1000];
    [self addTextArea:@"装备要求与取消安排" key:@"gear" initial:nil limit:500];
    [self addSwitch:@"免费自愿结伴，我已年满18岁并同意社区规范。" key:@"adult" initial:NO];
    __weak typeof(self) w = self;
    [self addButton:@"提交活动审核"
              style:@""
             action:^{
                 if (![w validateRequired:@[
                         @"title", @"route", @"city", @"area", @"location", @"description", @"gear",
                         @"distance", @"climb", @"capacity"
                     ]])
                     return;
                 if (![w.values[@"adult"] boolValue]) {
                     [w showMessage:@"请先确认免费结伴与成人声明。"];
                     return;
                 }
                 NSMutableDictionary *v = [w.values mutableCopy];
                 for (NSString *key in @[ @"distance", @"climb", @"capacity" ]) {
                     NSScanner *scanner = [NSScanner scannerWithString:[v[key] description]];
                     double number;
                     if (![scanner scanDouble:&number] || !scanner.isAtEnd) {
                         [w showMessage:@"距离、爬升和人数必须填写有效数字。"];
                         return;
                     }
                     v[key] = @(number);
                 }
                 NSError *e;
                 NSString *identifier = [w.store saveActivity:v editingId:w.objectId error:&e];
                 if (identifier)
                     [w pushRoute:@"activityReview" identifier:identifier];
                 else
                     [w showError:e];
             }];
    [self addNote:@"输入保存在本机草稿。审核入口仅为本地演示，不向其他人发布。"];
}
- (void)valuesDidChange {
    self.store.state[@"activityDraft"] = [self.values mutableCopy];
    [self.store commit];
}
@end
