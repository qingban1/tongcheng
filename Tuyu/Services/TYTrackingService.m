#import "TYTrackingService.h"
#import "TYLocalStore.h"
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
NSNotificationName const TYTrackingDidTickNotification = @"TYTrackingDidTickNotification";
@interface TYTrackingService () <CLLocationManagerDelegate>
@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, strong) CLLocationManager *locationManager;
@property(nonatomic, strong) CLLocation *lastLocation;
@property(nonatomic, copy) NSString *locationStatus;
@end
@implementation TYTrackingService
+ (instancetype)sharedService {
    static TYTrackingService *s;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        s = [self new];
    });
    return s;
}
- (instancetype)init {
    if ((self = [super init])) {
        _locationStatus = @"尚未采集位置";
        NSMutableDictionary *s = self.session;
        if (s) {
            s[@"paused"] = @YES;
            s[@"needsRecovery"] = @YES;
            [s removeObjectForKey:@"resumedAt"];
        }
        __weak typeof(self) weakSelf = self;
        _timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                 repeats:YES
                                                   block:^(NSTimer *timer) {
                                                       [weakSelf tick];
                                                   }];
        [NSRunLoop.mainRunLoop addTimer:_timer forMode:NSRunLoopCommonModes];
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(persist)
                                                   name:UIApplicationDidEnterBackgroundNotification
                                                 object:nil];
    }
    return self;
}
- (NSMutableDictionary *)session {
    return TYLocalStore.sharedStore.state[@"session"];
}
- (NSTimeInterval)elapsedSeconds {
    NSDictionary *s = self.session;
    if (!s)
        return 0;
    return [s[@"seconds"] doubleValue] +
           ([s[@"paused"] boolValue]
                ? 0
                : MAX(0, NSDate.date.timeIntervalSince1970 - [s[@"resumedAt"] doubleValue]));
}
- (void)tick {
    if (!self.session)
        return;
    [NSNotificationCenter.defaultCenter postNotificationName:TYTrackingDidTickNotification object:self];
    if (((NSInteger)self.elapsedSeconds) % 5 == 0)
        [self persist];
}
- (void)startMode:(NSString *)mode activityId:(NSString *)activityId {
    if (self.session)
        return;
    TYLocalStore *store = TYLocalStore.sharedStore;
    store.state[@"session"] = [@{
        @"id" : TYLocalStore.identifier,
        @"start" : @(NSDate.date.timeIntervalSince1970),
        @"seconds" : @0,
        @"resumedAt" : @(NSDate.date.timeIntervalSince1970),
        @"mode" : mode,
        @"paused" : @NO,
        @"needsRecovery" : @NO,
        @"markers" : [NSMutableArray new],
        @"points" : [NSMutableArray new],
        @"distance" : @0,
        @"activityId" : activityId ?: @""
    } mutableCopy];
    if ([mode isEqual:@"真实轨迹"])
        [self beginLocation];
    [store commit];
}
- (void)beginLocation {
    if (!self.locationManager) {
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 5;
        self.locationManager.activityType = CLActivityTypeFitness;
        self.locationManager.pausesLocationUpdatesAutomatically = NO;
    }
    CLAuthorizationStatus auth = self.locationManager.authorizationStatus;
    if (auth == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
        self.locationStatus = @"等待定位授权";
    } else if (auth == kCLAuthorizationStatusAuthorizedWhenInUse ||
               auth == kCLAuthorizationStatusAuthorizedAlways) {
        self.locationManager.allowsBackgroundLocationUpdates = YES;
        self.locationManager.showsBackgroundLocationIndicator = YES;
        [self.locationManager startUpdatingLocation];
        self.locationStatus = @"正在获取位置";
    } else
        self.locationStatus = @"定位未授权，仍可计时；不会生成虚假轨迹";
}
- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    if ([self.session[@"mode"] isEqual:@"真实轨迹"] && ![self.session[@"paused"] boolValue])
        [self beginLocation];
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    NSMutableDictionary *s = self.session;
    if (!s || [s[@"paused"] boolValue])
        return;
    for (CLLocation *p in locations) {
        if (p.horizontalAccuracy < 0 || p.horizontalAccuracy > 50 ||
            fabs(p.timestamp.timeIntervalSinceNow) > 20)
            continue;
        double distance = self.lastLocation ? [p distanceFromLocation:self.lastLocation] : 0,
               dt = self.lastLocation ? [p.timestamp timeIntervalSinceDate:self.lastLocation.timestamp] : 0;
        if (self.lastLocation && (dt <= 0 || (distance / MAX(dt, 1) > 12)))
            continue;
        NSMutableDictionary *point = [@{
            @"latitude" : @(p.coordinate.latitude),
            @"longitude" : @(p.coordinate.longitude),
            @"time" : @(p.timestamp.timeIntervalSince1970),
            @"accuracy" : @(p.horizontalAccuracy)
        } mutableCopy];
        if (self.lastLocation && dt > 60)
            point[@"break"] = @YES;
        else
            s[@"distance"] = @([s[@"distance"] doubleValue] + distance / 1000);
        [s[@"points"] addObject:point];
        self.lastLocation = p;
        self.locationStatus = @"定位可用 · 估算轨迹";
    }
    [self persist];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    self.locationStatus = @"定位暂不可用，计时继续";
    self.lastLocation = nil;
}
- (void)togglePause {
    NSMutableDictionary *s = self.session;
    if (!s)
        return;
    if ([s[@"paused"] boolValue]) {
        [self resume];
        return;
    }
    s[@"seconds"] = @(self.elapsedSeconds);
    s[@"paused"] = @YES;
    [s removeObjectForKey:@"resumedAt"];
    [self.locationManager stopUpdatingLocation];
    self.lastLocation = nil;
    [TYLocalStore.sharedStore commit];
}
- (void)resume {
    NSMutableDictionary *s = self.session;
    if (!s)
        return;
    s[@"paused"] = @NO;
    s[@"needsRecovery"] = @NO;
    s[@"resumedAt"] = @(NSDate.date.timeIntervalSince1970);
    if ([s[@"mode"] isEqual:@"真实轨迹"])
        [self beginLocation];
    [TYLocalStore.sharedStore commit];
}
- (void)persist {
    NSMutableDictionary *s = self.session;
    if (!s)
        return;
    if (![s[@"paused"] boolValue]) {
        s[@"seconds"] = @(self.elapsedSeconds);
        s[@"resumedAt"] = @(NSDate.date.timeIntervalSince1970);
    }
    [TYLocalStore.sharedStore commit];
}
- (NSString *)finish {
    NSMutableDictionary *s = self.session;
    if (!s)
        return nil;
    [self persist];
    NSMutableDictionary *t = [s mutableCopy];
    NSString *mode = s[@"mode"];
    t[@"title"] = [NSString stringWithFormat:@"我的徒步 %@", [TYLocalStore dateText:s[@"start"]]];
    t[@"photo"] = @"forest";
    t[@"sample"] = @([mode isEqual:@"示例轨迹"]);
    [t removeObjectForKey:@"paused"];
    [t removeObjectForKey:@"resumedAt"];
    [t removeObjectForKey:@"needsRecovery"];
    if ([mode isEqual:@"仅计时"])
        [t removeObjectForKey:@"distance"];
    if ([mode isEqual:@"示例轨迹"])
        t[@"distance"] = @3.28;
    [self.locationManager stopUpdatingLocation];
    self.lastLocation = nil;
    TYLocalStore *store = TYLocalStore.sharedStore;
    [store.state[@"trips"] insertObject:t atIndex:0];
    [store.state removeObjectForKey:@"session"];
    [store commit];
    return t[@"id"];
}
- (void)discard {
    [self.locationManager stopUpdatingLocation];
    self.lastLocation = nil;
    [TYLocalStore.sharedStore.state removeObjectForKey:@"session"];
    [TYLocalStore.sharedStore commit];
}
- (void)dealloc {
    [_timer invalidate];
    [NSNotificationCenter.defaultCenter removeObserver:self];
}
@end
