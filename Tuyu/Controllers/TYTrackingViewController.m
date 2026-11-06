#import "TYTrackingViewController.h"
#import "TYTrackingService.h"
@interface TYTrackingViewController ()
@property(nonatomic, strong) UILabel *clockLabel;
@property(nonatomic, strong) UILabel *gpsLabel;
@property(nonatomic, strong) UILabel *distanceLabel;
@property(nonatomic, strong) UIView *mapView;
@property(nonatomic) NSUInteger displayedPointCount;
@end
@implementation TYTrackingViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(updateClock)
                                               name:TYTrackingDidTickNotification
                                             object:nil];
}
- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}
- (void)updateClock {
    self.clockLabel.text = [TYLocalStore durationText:TYTrackingService.sharedService.elapsedSeconds];
    self.gpsLabel.text = TYTrackingService.sharedService.locationStatus;
    NSDictionary *session = TYTrackingService.sharedService.session;
    if ([session[@"mode"] isEqual:@"真实轨迹"]) {
        self.distanceLabel.text = [NSString stringWithFormat:@"%.2f km", [session[@"distance"] doubleValue]];
        NSArray *points = session[@"points"];
        if (points.count != self.displayedPointCount) {
            self.displayedPointCount = points.count;
            [TYDesign updateMap:self.mapView points:points];
        }
    }
}
- (void)renderContent {
    [super renderContent];
    self.mapView = nil;
    self.distanceLabel = nil;
    self.clockLabel = nil;
    self.gpsLabel = nil;
    self.displayedPointCount = 0;
    TYTrackingService *service = TYTrackingService.sharedService;
    NSDictionary *s = service.session;
    BOOL recovery = [self.screenMode isEqual:@"recovery"], finish = [self.screenMode isEqual:@"finish"];
    [self addBackTitle:recovery ? @"异常恢复" : finish ? @"结束确认" : @"徒步进行中"];
    if (!s) {
        [self addNote:@"还没有进行中的记录。"];
        return;
    }
    __weak typeof(self) w = self;
    if (recovery) {
        [self add:[TYDesign label:@"上次的记录，\n还没说再见。" size:28 weight:UIFontWeightBold]];
        [self addNote:[NSString stringWithFormat:@"已恢复最后保存的用时 %@。关闭期间不补算时间或轨迹。",
                                                 [TYLocalStore durationText:service.elapsedSeconds]]];
        [self addButton:@"恢复并继续记录"
                  style:@""
                 action:^{
                     [service resume];
                     w.screenMode = nil;
                     [w renderContent];
                 }];
        [self addButton:@"结束并保存记录"
                  style:@"outline"
                 action:^{
                     w.screenMode = @"finish";
                     [w renderContent];
                 }];
        return;
    }
    if (finish) {
        [self add:[TYDesign label:@"今天的山野，\n先走到这里？" size:28 weight:UIFontWeightBold]];
        NSMutableDictionary *metric = [s mutableCopy];
        metric[@"seconds"] = @(service.elapsedSeconds);
        if ([s[@"mode"] isEqual:@"仅计时"])
            [metric removeObjectForKey:@"distance"];
        if ([s[@"mode"] isEqual:@"示例轨迹"])
            metric[@"distance"] = @3.28;
        [self add:[TYDesign metrics:metric]];
        [self addButton:@"结束并保存"
                  style:@""
                 action:^{
                     NSString *identifier = [service finish];
                     if (identifier)
                         [w pushRoute:@"summary" identifier:identifier];
                 }];
        [self addButton:@"继续徒步"
                  style:@"outline"
                 action:^{
                     w.screenMode = nil;
                     [w renderContent];
                 }];
        return;
    }
    BOOL paused = [s[@"paused"] boolValue], only = [s[@"mode"] isEqual:@"仅计时"],
         sample = [s[@"mode"] isEqual:@"示例轨迹"];
    [self add:[TYDesign card:@[ [TYDesign label:paused ? @"已暂停"
                                                       : (only     ? @"仅计时记录中"
                                                          : sample ? @"示例轨迹记录中"
                                                                   : @"真实轨迹记录中")
                                           size:13
                                         weight:UIFontWeightSemibold] ]
                        dark:YES]];
    if (only)
        [self addNote:@"仅记录时间，不采集距离、位置或轨迹。"];
    else {
        self.mapView = [TYDesign mapWithPoints:s[@"points"] example:sample];
        [self add:self.mapView];
    }
    self.clockLabel = [TYDesign label:[TYLocalStore durationText:service.elapsedSeconds]
                                 size:48
                               weight:UIFontWeightSemibold];
    self.clockLabel.font = [UIFont monospacedDigitSystemFontOfSize:48 weight:UIFontWeightSemibold];
    self.clockLabel.textAlignment = NSTextAlignmentCenter;
    [self add:self.clockLabel];
    if (!only) {
        self.distanceLabel = [TYDesign
             label:[NSString stringWithFormat:@"%.2f km", sample ? 3.28 : [s[@"distance"] doubleValue]]
              size:28
            weight:UIFontWeightSemibold];
        [self add:self.distanceLabel];
        if (sample)
            [self addNote:@"固定示例距离 · 不代表实际步行"];
        else {
            self.gpsLabel = [TYDesign label:service.locationStatus size:12 weight:UIFontWeightRegular];
            [self add:self.gpsLabel];
        }
    }
    [self add:[TYDesign horizontalStack:@[
              [TYDesign button:paused ? @"继续记录" : @"暂停记录"
                         style:@""
                        action:^{
                            [service togglePause];
                            [w renderContent];
                        }],
              [TYDesign button:@"标记片刻"
                         style:@"outline"
                        action:^{
                            [w pushRoute:@"marker" identifier:nil];
                        }]
          ]]];
    [self addButton:@"结束本次徒步"
              style:@"outline"
             action:^{
                 w.screenMode = @"finish";
                 [w renderContent];
             }];
    [self addNote:@"切换页面不结束记录。系统终止后恢复到最后保存点，记录空段不会被补画。"];
}
@end
