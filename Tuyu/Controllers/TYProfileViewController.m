#import "TYProfileViewController.h"
@implementation TYProfileViewController
- (void)viewDidLoad {
    self.values = [self.store.state[@"profile"] mutableCopy];
    [super viewDidLoad];
}
- (void)renderContent {
    [super renderContent];
    [self addBackTitle:@"个人资料"];
    [self add:[TYDesign person:self.values[@"nickname"] subtitle:@"本机演示资料，不向其他设备同步"]];
    [self addField:@"昵称" key:@"nickname" initial:nil numeric:NO limit:20];
    [self addField:@"常用城市" key:@"city" initial:nil numeric:NO limit:20];
    [self addTextArea:@"个人简介" key:@"bio" initial:nil limit:200];
    [self addChoice:@"节奏偏好"
                key:@"pace"
            options:@[ @"轻松慢走", @"边走边拍", @"稳定行进" ]
            initial:@"边走边拍"];
    __weak typeof(self) w = self;
    [self addButton:@"保存个人资料"
              style:@""
             action:^{
                 if (![w validateRequired:@[ @"nickname", @"city" ]])
                     return;
                 w.store.state[@"profile"] = [w.values mutableCopy];
                 w.store.state[@"city"] = w.values[@"city"];
                 for (NSMutableDictionary *p in [w.store items:@"posts"])
                     if ([p[@"author"] isEqual:@"self"])
                         p[@"name"] = w.values[@"nickname"];
                 for (NSMutableDictionary *a in [w.store items:@"activities"])
                     if ([a[@"author"] isEqual:@"self"])
                         a[@"host"] = w.values[@"nickname"];
                 [w.store commit];
                 [w.navigationController popViewControllerAnimated:YES];
             }];
}
@end
