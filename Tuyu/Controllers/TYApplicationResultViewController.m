#import "TYApplicationResultViewController.h"
#import "TYTrackingService.h"
#import "TYArtwork.h"
@implementation TYApplicationResultViewController
- (void)renderContent {
    [super renderContent];
    __weak typeof(self) w = self;

    [self addBackTitle:@"报名结果"];
    NSString *s = [self.store applicationStatus:self.objectId];
    [self add:[TYDesign label:[s isEqual:@"approved"]
                                  ? @"报名已通过"
                                  : ([s isEqual:@"pending"] ? @"等待发起人确认" : @"本次申请未通过")
                         size:28
                       weight:UIFontWeightBold]];
    [self addNote:@"报名和审核发生在本机演示数据中，没有向其他用户发送申请。"];
    [self addButton:@"查看活动详情"
              style:@""
             action:^{
                 [w pushRoute:@"activity" identifier:w.objectId];
             }];
    return;
}
@end
