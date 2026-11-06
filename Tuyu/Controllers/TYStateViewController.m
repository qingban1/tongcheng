#import "TYStateViewController.h"
#import "TYTrackingService.h"
#import "TYArtwork.h"
@implementation TYStateViewController
- (void)renderContent {
    [super renderContent];
    NSString *mode = self.screenMode ?: @"privacy";
    __weak typeof(self) w = self;
    if ([mode isEqual:@"states"]) {
        [self addBackTitle:@"界面状态预览"];
        for (NSString *s in @[ @"empty", @"offline", @"error", @"recovery", @"loading" ]) {
            NSString *title = @{
                @"empty" : @"空白状态",
                @"offline" : @"离线状态",
                @"error" : @"加载失败",
                @"recovery" : @"异常恢复",
                @"loading" : @"加载中"
            }[s];
            [self addButton:title
                      style:@"outline"
                     action:^{
                         [w pushRoute:s identifier:nil];
                     }];
        }
        return;
    }

    NSString *title =
        @{@"empty" : @"空白状态",
          @"offline" : @"离线状态",
          @"error" : @"加载失败",
          @"loading" : @"加载中"}[mode];
    [self addBackTitle:title];
    NSString *text = @{
        @"empty" : @"第一段山野，等你出发。记录你的片刻与经验。",
        @"offline" : @"所有资源与记录均在本机。离线可以继续计时、标记和保存，没有尚未实现的同步队列。",
        @"error" : @"这是加载失败的样例状态。本版没有网络请求，本机记录不受影响。",
        @"loading" : @"正在读取山野故事…这是界面加载状态样例。"
    }[mode];
    [self addNote:text];
    if ([mode isEqual:@"loading"]) {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        [spinner startAnimating];
        [self add:spinner];
    }
    [self addButton:[mode isEqual:@"error"] ? @"重新加载"
                                            : ([mode isEqual:@"loading"] ? @"查看加载完成" : @"去徒步")
              style:@""
             action:^{
                 [w selectTab:[mode isEqual:@"error"] ? 1 : ([mode isEqual:@"loading"] ? 0 : 3)];
             }];
    return;
}
@end
