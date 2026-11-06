#import "TYPermissionViewController.h"
#import "TYTrackingService.h"
#import "TYArtwork.h"
@implementation TYPermissionViewController
- (void)renderContent {
    [super renderContent];
    __weak typeof(self) w = self;

    [self addBackTitle:@"定位与记录说明"];
    [self add:[TYDesign card:@[ [TYDesign label:@"只为记下，\n你走过的路。" size:28 weight:UIFontWeightBold] ]
                        dark:YES]];
    [self addSection:@"示例轨迹"];
    [self addText:@"显示一条自绘轨迹和3.28公里固定示例距离，不采集真实位置，不用于导航。"];
    [self addSection:@"仅计时"];
    [self addText:@"记录有效用时和沿途标记，不显示GPS、距离或轨迹。暂停不累计时间。"];
    [self addSection:@"真实记录"];
    [self addText:@"在设置中开启真实GPS后，点击开始徒步才申请定位。拒绝授权仍可计时，不会生成虚假轨迹。轨"
                  @"迹在本机保存，精度受环境影响。后台定位会增加耗电。系统终止后恢复到最后保存点，不补画"
                  @"中断期间的轨迹。"];
    [self addButton:@"开始示例徒步"
              style:@""
             action:^{
                 [TYTrackingService.sharedService startMode:@"示例轨迹" activityId:nil];
                 [w pushRoute:@"tracking" identifier:nil];
             }];
    [self addButton:@"仅计时模式"
              style:@"outline"
             action:^{
                 [TYTrackingService.sharedService startMode:@"仅计时" activityId:nil];
                 [w pushRoute:@"tracking" identifier:nil];
             }];
    return;
}
@end
