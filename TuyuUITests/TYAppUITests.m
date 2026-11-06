#import <XCTest/XCTest.h>
@interface TYAppUITests : XCTestCase
@property(nonatomic, strong) XCUIApplication *app;
@end
@implementation TYAppUITests
- (void)setUp {
    [super setUp];
    self.continueAfterFailure = NO;
    self.app = [XCUIApplication new];
    self.app.launchArguments = @[ @"--uitesting-reset" ];
    [self.app launch];
}
- (void)tap:(NSString *)name {
    XCUIElement *e = self.app.buttons[name];
    for (NSInteger i = 0; i < 8 && !e.hittable; i++)
        [self.app swipeUp];
    XCTAssertTrue(e.exists, @"Missing control: %@", name);
    [e tap];
}
- (void)registerDemoAccount {
    XCUIElement *phone = self.app.textFields[@"手机号"];
    [phone tap];
    [phone typeText:@"19900000000"];
    [self tap:@"生成演示验证码"];
    XCUIElement *codeLabel = self.app.staticTexts[@"demo-code"];
    XCTAssertTrue([codeLabel waitForExistenceWithTimeout:5]);
    NSString *text = codeLabel.label;
    XCTAssertTrue([text hasPrefix:@"本机演示验证码："]);
    NSString *code = [text substringFromIndex:text.length - 6];
    XCUIElement *codeField = self.app.textFields[@"验证码"];
    [codeField tap];
    [codeField typeText:code];
    XCUIElement *password = self.app.secureTextFields[@"密码"];
    for (NSInteger i = 0; i < 5 && !password.hittable; i++)
        [self.app swipeUp];
    [password tap];
    [password typeText:@"TuyuDemo88\n"];
    [self tap:@"注册并登录"];
}
- (void)testGuestGateRegistrationAndPasswordLogin {
    NSArray *tabs = @[ @"meet", @"records", @"hike", @"mine" ];
    NSArray *titles = @[ @"约行", @"记录", @"徒步", @"我的" ];
    for (NSUInteger i = 0; i < tabs.count; i++) {
        [self.app.buttons[[@"tab-" stringByAppendingString:tabs[i]]] tap];
        XCTAssertTrue([self.app.staticTexts[[@"登录后进入" stringByAppendingString:titles[i]]]
            waitForExistenceWithTimeout:4]);
        [self tap:@"关闭"];
        XCTAssertTrue(self.app.buttons[@"tab-square"].exists);
    }
    [self.app.buttons[@"tab-records"] tap];
    [self registerDemoAccount];
    XCTAssertTrue([self.app.staticTexts[@"我的山野护照"] waitForExistenceWithTimeout:5]);
    [self.app terminate];
    self.app.launchArguments = @[];
    [self.app launch];
    [self.app.buttons[@"tab-mine"] tap];
    XCTAssertTrue([self.app.staticTexts[@"登录后进入我的"] waitForExistenceWithTimeout:5]);
    XCUIElement *phone = self.app.textFields[@"手机号"];
    [phone tap];
    [phone typeText:@"19900000000"];
    XCUIElement *password = self.app.secureTextFields[@"密码"];
    [password tap];
    [password typeText:@"TuyuDemo88\n"];
    [self tap:@"登录"];
    XCTAssertTrue([self.app.buttons[@"设置"] waitForExistenceWithTimeout:5]);
}
- (void)testFiveTabsAndNativeScreens {
    for (NSString *tab in @[ @"square", @"meet", @"records", @"hike", @"mine" ]) {
        XCUIElement *b = self.app.buttons[[@"tab-" stringByAppendingString:tab]];
        XCTAssertTrue(b.exists);
        [b tap];
        if ([tab isEqualToString:@"meet"])
            [self registerDemoAccount];
        XCTAttachment *a = [XCTAttachment attachmentWithScreenshot:self.app.screenshot];
        a.name = tab;
        a.lifetime = XCTAttachmentLifetimeKeepAlways;
        [self addAttachment:a];
    }
    XCTAssertFalse(self.app.webViews.firstMatch.exists);
}
- (void)testTimerSaveAndReflection {
    [self.app.buttons[@"tab-hike"] tap];
    [self registerDemoAccount];
    [self tap:@"仅计时模式"];
    XCTAssertTrue([self.app.staticTexts[@"仅计时记录中"] waitForExistenceWithTimeout:5]);
    XCTAssertFalse(self.app.staticTexts[@"3.28 km"].exists);
    [self tap:@"暂停记录"];
    [self tap:@"结束本次徒步"];
    [self tap:@"结束并保存"];
    [self tap:@"一分钟复盘"];
    XCUIElement *text = self.app.textViews[@"给下次的一句提醒"];
    for (NSInteger i = 0; i < 6 && !text.hittable; i++)
        [self.app swipeUp];
    [text tap];
    [text typeText:@"下次带薄外套"];
    [self.app swipeUp];
    [self tap:@"保存私人复盘"];
    XCTAssertTrue(self.app.buttons[@"一分钟复盘"].exists);
}
@end
