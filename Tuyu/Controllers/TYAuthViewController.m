#import "TYAuthViewController.h"
#import "TYLocalAuthService.h"

@interface TYAuthViewController ()
@property(nonatomic, copy) NSString *mode;
@property(nonatomic, strong) UILabel *codeLabel;
@end

@implementation TYAuthViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.mode = TYLocalAuthService.sharedService.hasAccount ? @"密码登录" : @"注册";
}
- (void)renderContent {
    [super renderContent];
    __weak typeof(self) weakSelf = self;
    [self addTitle:@"注册登录"
           subtitle:@"同城徒遇 · 设备内演示"
        actionTitle:@"关闭"
             action:^{
                 [weakSelf finish:NO];
             }];
    [self
        add:[TYDesign label:[NSString stringWithFormat:@"登录后进入%@", self.destinationTitle ?: @"同城徒遇"]
                       size:24
                     weight:UIFontWeightBold]];
    [self addNote:@"请使用示例手机号和专用演示密码。验证码会直接显示在本页，不发送真实短信；本机仅支持一个演"
                  @"示账号。"];
    [self addChips:@[ @"注册", @"验证码登录", @"密码登录" ]
          selected:self.mode
            action:^(NSString *mode) {
                weakSelf.mode = mode;
                [weakSelf.values removeObjectForKey:@"code"];
                [weakSelf.values removeObjectForKey:@"password"];
                [weakSelf renderContent];
            }];
    BOOL registerMode = [self.mode isEqualToString:@"注册"];
    BOOL needsCode = ![self.mode isEqualToString:@"密码登录"];
    [self addField:@"手机号" key:@"phone" initial:nil numeric:YES limit:11];
    ((UITextField *)self.controls[@"phone"]).keyboardType = UIKeyboardTypeNumberPad;
    if (needsCode) {
        [self addButton:@"生成演示验证码"
                  style:@"outline"
                 action:^{
                     [weakSelf issueCode];
                 }];
        self.codeLabel = [TYDesign label:@"验证码仅在本页显示，5 分钟内有效。"
                                    size:13
                                  weight:UIFontWeightMedium];
        self.codeLabel.accessibilityIdentifier = @"demo-code";
        [self add:self.codeLabel];
        [self addField:@"验证码" key:@"code" initial:nil numeric:YES limit:6];
        ((UITextField *)self.controls[@"code"]).keyboardType = UIKeyboardTypeNumberPad;
    }
    if (registerMode || !needsCode) {
        [self addField:@"密码" key:@"password" initial:nil numeric:NO limit:64];
        UITextField *password = (UITextField *)self.controls[@"password"];
        password.secureTextEntry = YES;
        password.autocorrectionType = UITextAutocorrectionTypeNo;
        password.autocapitalizationType = UITextAutocapitalizationTypeNone;
        password.placeholder = registerMode ? @"设置 8–64 位演示密码" : @"输入本机演示密码";
    }
    [self addButton:registerMode ? @"注册并登录" : @"登录"
              style:@""
             action:^{
                 [weakSelf submit];
             }];
    [self addButton:@"暂不登录，返回广场"
              style:@"outline"
             action:^{
                 [weakSelf finish:NO];
             }];
}
- (void)issueCode {
    [self.view endEditing:YES];
    NSError *error = nil;
    NSString *code =
        [TYLocalAuthService.sharedService issueDemoCodeForPhone:self.values[@"phone"]
                                                    registering:[self.mode isEqualToString:@"注册"]
                                                          error:&error];
    if (!code) {
        [self showError:error];
        return;
    }
    self.codeLabel.text = [@"本机演示验证码：" stringByAppendingString:code];
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, self.codeLabel.text);
}
- (void)submit {
    [self.view endEditing:YES];
    TYLocalAuthService *auth = TYLocalAuthService.sharedService;
    NSError *error = nil;
    BOOL success;
    if ([self.mode isEqualToString:@"注册"])
        success = [auth registerPhone:self.values[@"phone"]
                                 code:self.values[@"code"]
                             password:self.values[@"password"]
                                error:&error];
    else if ([self.mode isEqualToString:@"验证码登录"])
        success = [auth loginPhone:self.values[@"phone"] code:self.values[@"code"] error:&error];
    else
        success = [auth loginPhone:self.values[@"phone"] password:self.values[@"password"] error:&error];
    if (!success) {
        [self showError:error];
        return;
    }
    [self finish:YES];
}
- (void)finish:(BOOL)authenticated {
    [self.values removeObjectForKey:@"password"];
    [self.values removeObjectForKey:@"code"];
    void (^callback)(BOOL) = self.completion;
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 if (callback)
                                     callback(authenticated);
                             }];
}
@end
