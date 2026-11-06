#import "TYDataManagementViewController.h"
#import "TYTrackingService.h"
#import "TYArtwork.h"
#import "TYLocalAuthService.h"
@implementation TYDataManagementViewController
- (void)renderContent {
    [super renderContent];
    NSString *mode = self.screenMode ?: @"privacy";
    __weak typeof(self) w = self;

    BOOL reset = [mode isEqual:@"reset"];
    [self addBackTitle:reset ? @"重置演示数据" : @"清除本机资料与记录"];
    [self add:[TYDesign label:reset ? @"从新的山野开始。" : @"离开之前，请确认。"
                         size:28
                       weight:UIFontWeightBold]];
    [self addNote:reset
                      ? @"清除更改、停止记录并恢复初始示例行程与合集。"
                      : @"清空本机资料、行程、照片、作品与报名，同时停止计时。同时清除演示账号，不会操作远程"
                        @"服务器。"];
    [self addSwitch:@"我了解本机数据将被清除" key:@"confirmed" initial:NO];
    [self addButton:reset ? @"确认重置演示数据" : @"确认清除本机资料"
              style:@"danger"
             action:^{
                 if (![w.values[@"confirmed"] boolValue]) {
                     [w showMessage:@"请先确认了解数据清除影响。"];
                     return;
                 }
                 [w confirm:@"确认清除本机数据"
                       text:@"该操作不能通过本App撤销。"
                     action:^{
                         [TYTrackingService.sharedService discard];
                         [TYArtwork removeUserImages];
                         [w.store resetDataKeepingExamples:reset];
                         if (reset)
                             [w.navigationController popToRootViewControllerAnimated:YES];
                         else {
                             [TYLocalAuthService.sharedService removeAccount];
                             [w returnToGuestSquare];
                         }
                     }];
             }];
    return;
}
@end
