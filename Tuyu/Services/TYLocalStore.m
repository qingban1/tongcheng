#import "TYLocalStore.h"
#import <math.h>
NSNotificationName const TYStoreDidChangeNotification = @"TYStoreDidChangeNotification";
static NSString *const TYStorageKey = @"TYNativeStateV1";
@interface TYLocalStore ()
@property(nonatomic, strong) NSMutableDictionary *state;
@property(nonatomic, strong) NSUserDefaults *defaults;
@property(nonatomic, strong, nullable) NSError *lastSaveError;
@end
@implementation TYLocalStore
+ (instancetype)sharedStore {
    static TYLocalStore *store;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        store = [[self alloc] initWithDefaults:NSUserDefaults.standardUserDefaults];
    });
    return store;
}
- (instancetype)initWithDefaults:(NSUserDefaults *)defaults {
    if ((self = [super init])) {
        _defaults = defaults;
        NSData *data = [defaults dataForKey:TYStorageKey];
        if (data)
            _state =
                [NSPropertyListSerialization propertyListWithData:data
                                                          options:NSPropertyListMutableContainersAndLeaves
                                                           format:nil
                                                            error:nil];
        if (![_state isKindOfClass:NSMutableDictionary.class] || ![_state[@"version"] isEqual:@1])
            [self resetDataKeepingExamples:YES];
    }
    return self;
}
+ (NSString *)identifier {
    return NSUUID.UUID.UUIDString;
}
+ (NSString *)dateText:(NSNumber *)timestamp {
    NSDateFormatter *f = [NSDateFormatter new];
    f.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    f.dateFormat = @"M月d日 EEE HH:mm";
    return [f stringFromDate:[NSDate dateWithTimeIntervalSince1970:timestamp.doubleValue]] ?: @"";
}
+ (NSString *)durationText:(NSTimeInterval)seconds {
    NSInteger n = MAX(0, (NSInteger)seconds);
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)n / 3600, (long)n / 60 % 60, (long)n % 60];
}
- (void)commit {
    NSAssert(NSThread.isMainThread, @"Local store is main-thread confined");
    NSError *error;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:self.state
                                                              format:NSPropertyListBinaryFormat_v1_0
                                                             options:0
                                                               error:&error];
    if (data) {
        [self.defaults setObject:data forKey:TYStorageKey];
    }
    self.lastSaveError = error;
    [NSNotificationCenter.defaultCenter postNotificationName:TYStoreDidChangeNotification object:self];
}
- (NSArray<NSMutableDictionary *> *)items:(NSString *)key {
    id a = self.state[key];
    return [a isKindOfClass:NSArray.class] ? a : @[];
}
- (NSMutableDictionary *)item:(NSString *)identifier in:(NSString *)key {
    if (!identifier.length)
        return nil;
    for (NSMutableDictionary *d in [self items:key])
        if ([d[@"id"] isEqual:identifier])
            return d;
    return nil;
}
- (NSNumber *)future:(NSInteger)days hour:(NSInteger)hour {
    NSCalendar *c = NSCalendar.currentCalendar;
    NSDate *d = [c dateByAddingUnit:NSCalendarUnitDay value:days toDate:NSDate.date options:0];
    d = [c dateBySettingHour:hour minute:30 second:0 ofDate:d options:0];
    return @([d timeIntervalSince1970]);
}
- (void)resetDataKeepingExamples:(BOOL)keep {
    self.state = [@{
        @"version" : @1,
        @"profile" : [@{
            @"nickname" : @"小遇",
            @"city" : @"杭州",
            @"pace" : @"边走边拍",
            @"bio" : @"喜欢慢慢走，喜欢林间的光。"
        } mutableCopy],
        @"city" : @"杭州",
        @"pace" : @"不限",
        @"filters" : [@{@"date" : @"不限", @"distance" : @"不限", @"available" : @NO} mutableCopy],
        @"applications" : [NSMutableDictionary new],
        @"activities" : [NSMutableArray new],
        @"trips" : [NSMutableArray new],
        @"posts" : [NSMutableArray new],
        @"collections" : [NSMutableArray new],
        @"requests" : [NSMutableArray new],
        @"notices" : [NSMutableArray new],
        @"questions" : [NSMutableArray new],
        @"messages" : [NSMutableArray new],
        @"reports" : [NSMutableArray new],
        @"feedback" : [NSMutableArray new],
        @"liked" : [NSMutableArray new],
        @"saved" : [NSMutableArray new],
        @"following" : [NSMutableArray new],
        @"blocked" : [NSMutableArray new],
        @"notifications" : @YES,
        @"realTracking" : @NO
    } mutableCopy];
    NSArray *seeds = @[
        @[
            @"forest", @"龙井山径 · 把秋天走慢一点", @"龙井山径", @"西湖区", @"龙井村入口公共集合区", @8.6,
            @320, @6, @4, @"边走边拍", @"forest", @"山野阿橙", @"cheng", @3
        ],
        @[
            @"creek", @"九溪听风 · 轻松走一段", @"九溪步道", @"西湖区", @"九溪公交站公共等候区", @4.2, @100,
            @8, @7, @"轻松慢走", @"forest", @"阿禾", @"he", @9
        ],
        @[
            @"ridge", @"山脊行进 · 周末向上", @"郊外山径", @"余杭区", @"步道公共入口", @12.4, @780, @4, @4,
            @"稳定行进", @"mountain", @"阿岳", @"yue", @5
        ]
    ];
    for (NSArray *s in seeds) {
        NSMutableDictionary *a = [@{
            @"id" : s[0],
            @"title" : s[1],
            @"route" : s[2],
            @"city" : @"杭州",
            @"area" : s[3],
            @"location" : s[4],
            @"distance" : s[5],
            @"climb" : s[6],
            @"capacity" : s[7],
            @"joined" : s[8],
            @"pace" : s[9],
            @"photo" : s[10],
            @"host" : s[11],
            @"author" : s[12],
            @"date" : [self future:[s[13] integerValue] hour:8],
            @"end" : [self future:[s[13] integerValue] hour:13],
            @"deadline" : [self future:[s[13] integerValue] - 1 hour:20],
            @"status" : @"approved",
            @"description" : @"沿林间步道出发，途中安排两次休息。遇到喜欢的风景就停一会儿。",
            @"gear" : @"防滑徒步鞋、饮水、薄外套和随身垃圾袋。请根据自身情况选择。"
        } mutableCopy];
        [self.state[@"activities"] addObject:a];
    }
    if (keep) {
        NSMutableDictionary *t = [@{
            @"id" : @"sample",
            @"title" : @"森林有自己的呼吸",
            @"start" : [self future:-4 hour:8],
            @"seconds" : @9360,
            @"distance" : @8.62,
            @"mode" : @"示例轨迹",
            @"sample" : @YES,
            @"photo" : @"forest",
            @"markers" : [NSMutableArray new],
            @"points" : [NSMutableArray new],
            @"reflection" : [@{
                @"effort" : @"适中",
                @"pace" : @"合适",
                @"gear" : @"徒步鞋很合适。",
                @"tip" : @"山脊风大，下次带一件薄外套。"
            } mutableCopy]
        } mutableCopy];
        [self.state[@"trips"] addObject:t];
        [self.state[@"collections"] addObject:[@{
                                        @"id" : @"autumn",
                                        @"title" : @"把秋天走成一本书",
                                        @"tripIds" : [NSMutableArray arrayWithObject:@"sample"],
                                        @"public" : @NO
                                    } mutableCopy]];
    }
    [self.state[@"posts"]
        addObject:[@{
            @"id" : @"editorial",
            @"title" : @"把周末还给山野",
            @"body" : @"不赶路，也能遇见好风景。沿着林间步道，收集阳光、树影和同行人的笑声。",
            @"author" : @"cheng",
            @"name" : @"山野阿橙",
            @"photo" : @"mountain",
            @"distance" : @8.62,
            @"seconds" : @9360,
            @"tip" : @"山脊风大，下次带一件薄外套。",
            @"status" : @"public",
            @"sample" : @YES,
            @"template" : @"照片故事"
        } mutableCopy]];
    [self commit];
}
- (NSDictionary *)statistics {
    double distance = 0;
    NSMutableSet *days = [NSMutableSet new];
    NSDateFormatter *f = [NSDateFormatter new];
    f.dateFormat = @"yyyy-MM-dd";
    for (NSDictionary *t in [self items:@"trips"]) {
        distance += [t[@"distance"] doubleValue];
        [days addObject:[f stringFromDate:[NSDate dateWithTimeIntervalSince1970:[t[@"start"] doubleValue]]]];
    }
    return @{@"count" : @([self items:@"trips"].count), @"distance" : @(distance), @"days" : @(days.count)};
}
- (NSString *)statusForActivity:(NSDictionary *)a {
    double now = NSDate.date.timeIntervalSince1970;
    if ([a[@"cancelled"] boolValue])
        return @"已取消";
    if ([a[@"status"] isEqual:@"pending"])
        return @"审核中";
    if ([a[@"status"] isEqual:@"rejected"])
        return @"未通过";
    if (now >= [a[@"end"] doubleValue])
        return @"已结束";
    if (now >= [a[@"date"] doubleValue])
        return @"进行中";
    if (now >= [a[@"deadline"] doubleValue])
        return @"已截止";
    if ([a[@"joined"] integerValue] >= [a[@"capacity"] integerValue])
        return @"已满员";
    return @"招募中";
}
- (NSString *)applicationStatus:(NSString *)identifier {
    return self.state[@"applications"][identifier][@"status"] ?: @"none";
}
- (BOOL)canAccessActivity:(NSDictionary *)a {
    return [a[@"author"] isEqual:@"self"] || [[self applicationStatus:a[@"id"]] isEqual:@"approved"];
}
- (BOOL)fail:(NSString *)text error:(NSError **)error {
    if (error)
        *error = [NSError errorWithDomain:@"TYValidation"
                                     code:1
                                 userInfo:@{NSLocalizedDescriptionKey : text}];
    return NO;
}
- (BOOL)applyToActivity:(NSString *)identifier values:(NSDictionary *)values error:(NSError **)error {
    NSDictionary *a = [self item:identifier in:@"activities"];
    if (!a || ![[self statusForActivity:a] isEqual:@"招募中"] || [a[@"author"] isEqual:@"self"] ||
        [self containsIdentifier:a[@"author"] in:@"blocked"])
        return [self fail:@"当前活动不可报名。" error:error];
    NSString *s = [self applicationStatus:identifier];
    if (![s isEqual:@"none"])
        return [self fail:@"该活动已有申请，请勿重复提交。" error:error];
    NSMutableDictionary *v = [values mutableCopy];
    v[@"status"] = @"pending";
    self.state[@"applications"][identifier] = v;
    [self addMessage:@"同行申请已提交，等待发起人审核。" type:@"活动" route:@"activity" objectId:identifier];
    [self commit];
    return YES;
}
- (BOOL)setApplication:(NSString *)identifier status:(NSString *)status error:(NSError **)error {
    NSMutableDictionary *a = [self item:identifier in:@"activities"],
                        *application = self.state[@"applications"][identifier];
    if (!application)
        return [self fail:@"申请已不存在。" error:error];
    NSString *old = application[@"status"];
    if ([status isEqual:@"none"]) {
        if ([old isEqual:@"approved"])
            a[@"joined"] = @(MAX(0, [a[@"joined"] integerValue] - 1));
        [self.state[@"applications"] removeObjectForKey:identifier];
    } else {
        if (![old isEqual:@"pending"])
            return [self fail:@"申请状态已变化。" error:error];
        if ([status isEqual:@"approved"] && (![[self statusForActivity:a] isEqual:@"招募中"] ||
                                             [self containsIdentifier:a[@"author"] in:@"blocked"]))
            return [self fail:@"名额已满、截止或活动不可报名。" error:error];
        application[@"status"] = status;
        if ([status isEqual:@"approved"])
            a[@"joined"] = @([a[@"joined"] integerValue] + 1);
    }
    [self addMessage:[status isEqual:@"approved"]
                         ? @"演示：报名已通过，请核对集合信息。"
                         : ([status isEqual:@"rejected"] ? @"演示：报名未通过。" : @"你已退出或撤回申请。")
                type:@"活动"
               route:@"activity"
            objectId:identifier];
    [self commit];
    return YES;
}
- (NSString *)saveActivity:(NSDictionary *)v editingId:(NSString *)editingId error:(NSError **)error {
    for (NSString *k in @[ @"title", @"route", @"city", @"area", @"location", @"description", @"gear" ]) {
        if (![v[k] isKindOfClass:NSString.class] ||
            ![v[k] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet].length) {
            [self fail:@"请完整填写所有必填内容。" error:error];
            return nil;
        }
    }
    double now = NSDate.date.timeIntervalSince1970, start = [v[@"date"] doubleValue],
           end = [v[@"end"] doubleValue], deadline = [v[@"deadline"] doubleValue],
           d = [v[@"distance"] doubleValue], climb = [v[@"climb"] doubleValue],
           capacity = [v[@"capacity"] doubleValue];
    if (!isfinite(start) || !isfinite(end) || !isfinite(deadline) || !isfinite(d) || !isfinite(climb) ||
        !isfinite(capacity) || start <= now || end <= start || deadline <= now || deadline > start ||
        d < .1 || d > 100 || climb < 0 || climb > 5000 || floor(climb) != climb || capacity < 2 ||
        capacity > 12 || floor(capacity) != capacity) {
        [self fail:@"请检查时间、距离、爬升和人数范围。" error:error];
        return nil;
    }
    for (NSDictionary *a in [self items:@"activities"])
        if ([a[@"author"] isEqual:@"self"] && ![a[@"id"] isEqual:editingId] && ![a[@"cancelled"] boolValue] &&
            ![a[@"status"] isEqual:@"rejected"] && [a[@"end"] doubleValue] > now) {
            [self fail:@"已有未结束的约行，请先取消或等待结束。" error:error];
            return nil;
        }
    NSMutableDictionary *a = [v mutableCopy];
    NSString *identifier = editingId ?: self.class.identifier;
    a[@"id"] = identifier;
    a[@"author"] = @"self";
    a[@"host"] = self.state[@"profile"][@"nickname"];
    a[@"status"] = @"pending";
    a[@"joined"] = @1;
    a[@"photo"] = @"forest";
    NSMutableArray *all = self.state[@"activities"];
    NSIndexSet *indexes =
        [all indexesOfObjectsPassingTest:^BOOL(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            return [obj[@"id"] isEqual:identifier];
        }];
    [all removeObjectsAtIndexes:indexes];
    [all insertObject:a atIndex:0];
    [self.state removeObjectForKey:@"activityDraft"];
    [self addMessage:@"约行已提交，等待演示审核。" type:@"系统" route:@"activityReview" objectId:identifier];
    [self commit];
    return identifier;
}
- (void)moderateActivity:(NSString *)identifier approved:(BOOL)approved {
    NSMutableDictionary *a = [self item:identifier in:@"activities"];
    if (![a[@"author"] isEqual:@"self"])
        return;
    a[@"status"] = approved ? @"approved" : @"rejected";
    a[@"reason"] = approved ? @"" : @"请完善路线说明与装备要求。";
    [self commit];
}
- (void)cancelActivity:(NSString *)identifier reason:(NSString *)reason {
    NSMutableDictionary *a = [self item:identifier in:@"activities"];
    if (![a[@"author"] isEqual:@"self"])
        return;
    a[@"cancelled"] = @YES;
    a[@"cancelReason"] = reason;
    [self addMessage:@"发起的约行已取消，报名关闭。" type:@"活动" route:@"activity" objectId:identifier];
    [self commit];
}
- (BOOL)decideRequest:(NSString *)identifier approved:(BOOL)approved error:(NSError **)error {
    NSMutableDictionary *r = [self item:identifier in:@"requests"], *a = [self item:r[@"activityId"]
                                                                                 in:@"activities"];
    if (!r || ![r[@"status"] isEqual:@"pending"] || ![a[@"author"] isEqual:@"self"])
        return [self fail:@"申请不存在或无权处理。" error:error];
    if (approved && ![[self statusForActivity:a] isEqual:@"招募中"])
        return [self fail:@"名额已满或报名已截止。" error:error];
    r[@"status"] = approved ? @"approved" : @"rejected";
    if (approved)
        a[@"joined"] = @([a[@"joined"] integerValue] + 1);
    [self commit];
    return YES;
}
- (void)deleteTrip:(NSString *)identifier {
    NSMutableDictionary *t = [self item:identifier in:@"trips"];
    if (t)
        [self.state[@"trips"] removeObject:t];
    for (NSMutableDictionary *c in [self items:@"collections"])
        [c[@"tripIds"] removeObject:identifier];
    for (NSMutableDictionary *p in [self items:@"posts"])
        if ([p[@"tripId"] isEqual:identifier])
            [p removeObjectForKey:@"tripId"];
    NSMutableDictionary *d = self.state[@"draft"];
    if ([d[@"tripId"] isEqual:identifier]) {
        [d removeObjectForKey:@"tripId"];
        d[@"showMetrics"] = @NO;
        d[@"showTip"] = @NO;
    }
    [self commit];
}
- (NSString *)publishDraftWithError:(NSError **)error {
    NSDictionary *d = self.state[@"draft"];
    if (![d[@"title"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet]
             .length) {
        [self fail:@"请填写作品标题。" error:error];
        return nil;
    }
    NSMutableDictionary *p = [@{
        @"id" : self.class.identifier,
        @"title" : d[@"title"],
        @"body" : d[@"body"] ?: @"",
        @"template" : d[@"template"] ?: @"照片故事",
        @"photo" : d[@"photo"] ?: @"forest",
        @"author" : @"self",
        @"name" : self.state[@"profile"][@"nickname"],
        @"status" : @"pending"
    } mutableCopy];
    NSDictionary *t = [self item:d[@"tripId"] in:@"trips"];
    if (t) {
        p[@"tripId"] = t[@"id"];
        p[@"sample"] = t[@"sample"] ?: @NO;
    }
    if ([d[@"showMetrics"] boolValue] && t) {
        p[@"seconds"] = t[@"seconds"];
        if (t[@"distance"])
            p[@"distance"] = t[@"distance"];
    }
    if ([d[@"showTip"] boolValue] && t[@"reflection"][@"tip"])
        p[@"tip"] = t[@"reflection"][@"tip"];
    NSString *editingId = d[@"editingId"];
    NSMutableDictionary *old = [self item:editingId in:@"posts"];
    if (old && [old[@"author"] isEqual:@"self"])
        [self.state[@"posts"] removeObject:old];
    [self.state[@"posts"] insertObject:p atIndex:0];
    [self.state removeObjectForKey:@"draft"];
    [self addMessage:@"作品已提交，等待演示审核。" type:@"系统" route:@"postReview" objectId:p[@"id"]];
    [self commit];
    return p[@"id"];
}
- (void)moderatePost:(NSString *)identifier status:(NSString *)status {
    NSMutableDictionary *p = [self item:identifier in:@"posts"];
    if (![p[@"author"] isEqual:@"self"])
        return;
    p[@"status"] = status;
    p[@"reason"] = [status isEqual:@"rejected"]
                       ? @"示例原因：请补充真实经历，避免误导性描述。"
                       : ([status isEqual:@"removed"] ? @"示例原因：内容需要重新核实。" : @"");
    [self commit];
}
- (BOOL)containsIdentifier:(NSString *)identifier in:(NSString *)key {
    return identifier.length && [self.state[key] containsObject:identifier];
}
- (void)toggleIdentifier:(NSString *)identifier in:(NSString *)key {
    if (!identifier.length)
        return;
    NSMutableArray *a = self.state[key];
    if ([a containsObject:identifier])
        [a removeObject:identifier];
    else
        [a addObject:identifier];
    [self commit];
}
- (void)addMessage:(NSString *)text
              type:(NSString *)type
             route:(NSString *)route
          objectId:(NSString *)objectId {
    [self.state[@"messages"] insertObject:[@{
                                 @"id" : self.class.identifier,
                                 @"text" : text,
                                 @"type" : type,
                                 @"route" : route,
                                 @"objectId" : objectId ?: @"",
                                 @"read" : @NO
                             } mutableCopy]
                                  atIndex:0];
}
@end
