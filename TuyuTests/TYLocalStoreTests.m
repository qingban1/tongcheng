#import <XCTest/XCTest.h>
#import "TYLocalStore.h"
#import "TYRouter.h"
#import "TYArtwork.h"
#import "TYLocalAuthService.h"
@interface TYLocalStoreTests : XCTestCase
@property(nonatomic, strong) TYLocalStore *store;
@property(nonatomic, strong) NSUserDefaults *defaults;
@property(nonatomic, copy) NSString *suite;
@end
@implementation TYLocalStoreTests
- (void)setUp {
    [super setUp];
    self.suite = [@"TYTests." stringByAppendingString:NSUUID.UUID.UUIDString];
    self.defaults = [[NSUserDefaults alloc] initWithSuiteName:self.suite];
    self.store = [[TYLocalStore alloc] initWithDefaults:self.defaults];
}
- (void)tearDown {
    [self.defaults removePersistentDomainForName:self.suite];
    [super tearDown];
}
- (void)testApplicationCapacityAndWithdrawalPrivacy {
    NSMutableDictionary *a = [self.store item:@"forest" in:@"activities"];
    NSInteger before = [a[@"joined"] integerValue];
    NSError *e;
    XCTAssertTrue([self.store applyToActivity:@"forest" values:@{@"intro" : @"同行"} error:&e]);
    XCTAssertFalse([self.store canAccessActivity:a]);
    XCTAssertTrue([self.store setApplication:@"forest" status:@"approved" error:&e]);
    XCTAssertEqual([a[@"joined"] integerValue], before + 1);
    XCTAssertTrue([self.store canAccessActivity:a]);
    XCTAssertTrue([self.store setApplication:@"forest" status:@"none" error:&e]);
    XCTAssertEqual([a[@"joined"] integerValue], before);
    XCTAssertFalse([self.store canAccessActivity:a]);
}
- (void)testFullActivityRejectsApplication {
    NSError *e;
    XCTAssertFalse([self.store applyToActivity:@"ridge" values:@{} error:&e]);
    XCTAssertNotNil(e);
}
- (void)testSharingOnlyPublishesSelectedSnapshotFields {
    self.store.state[@"draft"] = [@{
        @"title" : @"私密测试",
        @"body" : @"文字",
        @"tripId" : @"sample",
        @"photo" : @"forest",
        @"showMetrics" : @NO,
        @"showTip" : @NO
    } mutableCopy];
    NSError *e;
    NSString *identifier = [self.store publishDraftWithError:&e];
    NSDictionary *p = [self.store item:identifier in:@"posts"];
    XCTAssertNotNil(p);
    XCTAssertNil(p[@"distance"]);
    XCTAssertNil(p[@"seconds"]);
    XCTAssertNil(p[@"tip"]);
    XCTAssertNil(p[@"points"]);
    XCTAssertEqualObjects(p[@"status"], @"pending");
}
- (void)testDeletingTripUpdatesCollectionsAndStatistics {
    [self.store deleteTrip:@"sample"];
    XCTAssertEqual([self.store.statistics[@"count"] integerValue], 0);
    XCTAssertEqual([[self.store item:@"autumn" in:@"collections"][@"tripIds"] count], 0);
}
- (void)testPersistenceAndMutableRestoration {
    self.store.state[@"profile"][@"nickname"] = @"测试山友";
    [self.store commit];
    TYLocalStore *restored = [[TYLocalStore alloc] initWithDefaults:self.defaults];
    XCTAssertEqualObjects(restored.state[@"profile"][@"nickname"], @"测试山友");
    restored.state[@"profile"][@"nickname"] = @"可修改";
    XCTAssertEqualObjects(restored.state[@"profile"][@"nickname"], @"可修改");
}
- (void)testTimerOnlyDoesNotIncreaseDistance {
    double before = [self.store.statistics[@"distance"] doubleValue];
    [self.store.state[@"trips"] addObject:[@{
                                    @"id" : @"timer",
                                    @"start" : @(NSDate.date.timeIntervalSince1970),
                                    @"seconds" : @60,
                                    @"mode" : @"仅计时"
                                } mutableCopy]];
    XCTAssertEqualWithAccuracy([self.store.statistics[@"distance"] doubleValue], before, .0001);
}
- (void)testAllNativeRoutesCreateCompleteViews {
    TYLocalStore *store = TYLocalStore.sharedStore;
    [store resetDataKeepingExamples:YES];
    NSMutableDictionary *owned = [[store item:@"forest" in:@"activities"] mutableCopy];
    owned[@"id"] = @"owned";
    owned[@"author"] = @"self";
    [store.state[@"activities"] addObject:owned];
    NSDictionary *ids = @{
        @"post" : @"editorial",
        @"author" : @"editorial",
        @"activity" : @"forest",
        @"apply" : @"forest",
        @"applicationResult" : @"forest",
        @"participants" : @"owned",
        @"activityReview" : @"owned",
        @"notice" : @"owned",
        @"journal" : @"sample",
        @"reflection" : @"sample",
        @"summary" : @"sample",
        @"collection" : @"autumn"
    };
    NSArray *routes = @[
        @"square",         @"meet",
        @"records",        @"hike",
        @"mine",           @"post",
        @"author",         @"share",
        @"sharePreview",   @"postReview",
        @"activity",       @"createActivity",
        @"apply",          @"applicationResult",
        @"activityReview", @"myActivities",
        @"participants",   @"notice",
        @"filter",         @"city",
        @"journal",        @"summary",
        @"reflection",     @"passport",
        @"collection",     @"collectionEditor",
        @"tracking",       @"recovery",
        @"marker",         @"settings",
        @"profile",        @"messages",
        @"myWorks",        @"favorites",
        @"reviews",        @"blocked",
        @"privacy",        @"guidelines",
        @"report",         @"feedback",
        @"permission",     @"deleteData",
        @"reset",          @"states",
        @"empty",          @"offline",
        @"error",          @"loading"
    ];
    for (NSString *route in routes) {
        @autoreleasepool {
            UIViewController *v = [TYRouter controllerForRoute:route identifier:ids[route]];
            XCTAssertNoThrow([v loadViewIfNeeded], @"%@", route);
            XCTAssertNoThrow([v viewWillAppear:NO], @"%@", route);
            XCTAssertNotNil(v.view);
        }
    }
}
- (void)testArtworkContainsRealImagePixels {
    for (NSString *key in @[ @"mountain", @"forest" ]) {
        UIImage *image = [TYArtwork imageForKey:key];
        XCTAssertNotNil(image);
        XCTAssertGreaterThan(image.size.width, 800);
        unsigned char pixels[8 * 8 * 4] = {0};
        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
        CGContextRef context =
            CGBitmapContextCreate(pixels, 8, 8, 8, 8 * 4, space, kCGImageAlphaPremultipliedLast);
        CGContextDrawImage(context, CGRectMake(0, 0, 8, 8), image.CGImage);
        NSInteger sum = 0;
        for (NSInteger i = 0; i < 64; i++)
            sum += pixels[i * 4] + pixels[i * 4 + 1] + pixels[i * 4 + 2];
        XCTAssertGreaterThan(sum, 10000, @"%@ should not decode to a black rectangle", key);
        CGContextRelease(context);
        CGColorSpaceRelease(space);
    }
}

- (void)testLocalRegistrationPasswordAndFreshSession {
    TYLocalAuthService *auth = [[TYLocalAuthService alloc] initWithDefaults:self.defaults];
    NSError *error = nil;
    NSString *phone = @"19900000000";
    NSString *code = [auth issueDemoCodeForPhone:phone registering:YES error:&error];
    XCTAssertEqual(code.length, 6);
    NSString *wrong = [code isEqualToString:@"000000"] ? @"000001" : @"000000";
    XCTAssertFalse([auth registerPhone:phone code:wrong password:@"TuyuDemo88" error:&error]);
    XCTAssertTrue([auth registerPhone:phone code:code password:@"TuyuDemo88" error:&error]);
    XCTAssertTrue(auth.authenticated);
    XCTAssertEqualObjects(auth.maskedPhone, @"199****0000");
    NSDictionary *record = [self.defaults dictionaryForKey:@"TYDemoAccountV1"];
    XCTAssertNil(record[@"password"]);
    XCTAssertNil(record[@"code"]);
    XCTAssertEqual([record[@"digest"] length], 32);
    TYLocalAuthService *reopened = [[TYLocalAuthService alloc] initWithDefaults:self.defaults];
    XCTAssertFalse(reopened.authenticated);
    XCTAssertTrue(reopened.hasAccount);
    XCTAssertFalse([reopened loginPhone:phone password:@"Incorrect88" error:&error]);
    XCTAssertTrue([reopened loginPhone:phone password:@"TuyuDemo88" error:&error]);
    [reopened logout];
    NSString *loginCode = [reopened issueDemoCodeForPhone:phone registering:NO error:&error];
    XCTAssertEqual(loginCode.length, 6);
    XCTAssertTrue([reopened loginPhone:phone code:loginCode error:&error]);
    [reopened logout];
    XCTAssertFalse([reopened loginPhone:phone code:loginCode error:&error]);
    [reopened removeAccount];
    XCTAssertFalse(reopened.hasAccount);
}
@end
