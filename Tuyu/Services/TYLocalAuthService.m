#import "TYLocalAuthService.h"
#import <CommonCrypto/CommonKeyDerivation.h>
#import <CommonCrypto/CommonCryptoError.h>
#import <Security/Security.h>

static NSString *const TYAccountKey = @"TYDemoAccountV1";
static const uint TYDerivationRounds = 120000;
@interface TYLocalAuthService ()
@property(nonatomic, strong) NSUserDefaults *defaults;
@property(nonatomic, readwrite, getter=isAuthenticated) BOOL authenticated;
@property(nonatomic, copy, nullable) NSString *pendingPhone;
@property(nonatomic, copy, nullable) NSString *pendingCode;
@property(nonatomic) BOOL registrationCode;
@property(nonatomic, strong, nullable) NSDate *issuedAt;
@property(nonatomic) NSUInteger codeAttempts;
@property(nonatomic) NSUInteger passwordFailures;
@property(nonatomic, strong, nullable) NSDate *passwordRetryAt;
@end

@implementation TYLocalAuthService
+ (instancetype)sharedService {
    static TYLocalAuthService *service;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        service = [[self alloc] initWithDefaults:NSUserDefaults.standardUserDefaults];
    });
    return service;
}
- (instancetype)initWithDefaults:(NSUserDefaults *)defaults {
    if ((self = [super init]))
        _defaults = defaults;
    return self;
}
- (NSDictionary *)account {
    return [self.defaults dictionaryForKey:TYAccountKey];
}
- (BOOL)hasAccount {
    return [self account] != nil;
}
- (NSString *)maskedPhone {
    NSString *phone = [self account][@"phone"];
    if (phone.length != 11)
        return nil;
    return [NSString stringWithFormat:@"%@****%@", [phone substringToIndex:3], [phone substringFromIndex:7]];
}
- (NSString *)normalizedPhone:(NSString *)phone {
    return [phone stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
}
- (BOOL)validPhone:(NSString *)phone {
    return phone.length == 11 && [phone hasPrefix:@"1"] &&
           [phone rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]
                                              .invertedSet]
                   .location == NSNotFound;
}
- (BOOL)fail:(NSString *)message error:(NSError **)error {
    if (error)
        *error = [NSError errorWithDomain:@"TYLocalDemoAuth"
                                     code:1
                                 userInfo:@{NSLocalizedDescriptionKey : message}];
    return NO;
}
- (NSString *)issueDemoCodeForPhone:(NSString *)phone registering:(BOOL)registering error:(NSError **)error {
    phone = [self normalizedPhone:phone];
    if (![self validPhone:phone]) {
        [self fail:@"请输入以 1 开头的 11 位演示手机号。" error:error];
        return nil;
    }
    if (registering && self.hasAccount) {
        [self fail:@"本机已有演示账号，请切换到登录。" error:error];
        return nil;
    }
    if (!registering && ![[self account][@"phone"] isEqualToString:phone]) {
        [self fail:@"该手机号未在本机注册，请先注册演示账号。" error:error];
        return nil;
    }
    if (self.issuedAt && -self.issuedAt.timeIntervalSinceNow < 30) {
        [self fail:@"请等待 30 秒后重新生成演示验证码。" error:error];
        return nil;
    }
    self.pendingPhone = phone;
    self.pendingCode = [NSString stringWithFormat:@"%06u", arc4random_uniform(1000000)];
    self.registrationCode = registering;
    self.issuedAt = NSDate.date;
    self.codeAttempts = 0;
    return self.pendingCode;
}
- (BOOL)checkCode:(NSString *)code
            phone:(NSString *)phone
      registering:(BOOL)registering
            error:(NSError **)error {
    if (!self.pendingCode || ![self.pendingPhone isEqualToString:phone] ||
        self.registrationCode != registering || -self.issuedAt.timeIntervalSinceNow >= 300 ||
        self.codeAttempts >= 5)
        return [self fail:@"请为当前手机号重新生成演示验证码。" error:error];
    self.codeAttempts++;
    if (![self.pendingCode isEqualToString:code])
        return [self fail:@"演示验证码不正确。" error:error];
    return YES;
}
- (NSData *)digestForPassword:(NSString *)password salt:(NSData *)salt {
    NSData *bytes = [password dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *digest = [NSMutableData dataWithLength:32];
    int result =
        CCKeyDerivationPBKDF(kCCPBKDF2, bytes.bytes, bytes.length, salt.bytes, salt.length,
                             kCCPRFHmacAlgSHA256, TYDerivationRounds, digest.mutableBytes, digest.length);
    return result == kCCSuccess ? digest : nil;
}
- (BOOL)registerPhone:(NSString *)phone
                 code:(NSString *)code
             password:(NSString *)password
                error:(NSError **)error {
    phone = [self normalizedPhone:phone];
    if (self.hasAccount)
        return [self fail:@"本机已有演示账号，请登录。" error:error];
    if (![self validPhone:phone])
        return [self fail:@"请输入以 1 开头的 11 位演示手机号。" error:error];
    if (password.length < 8 || password.length > 64 ||
        ![password stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet].length)
        return [self fail:@"请设置 8–64 位演示密码，不要使用真实账号密码。" error:error];
    if (![self checkCode:code phone:phone registering:YES error:error])
        return NO;
    NSMutableData *salt = [NSMutableData dataWithLength:16];
    if (SecRandomCopyBytes(kSecRandomDefault, salt.length, salt.mutableBytes) != errSecSuccess)
        return [self fail:@"暂时无法创建本机演示账号。" error:error];
    NSData *digest = [self digestForPassword:password salt:salt];
    if (!digest)
        return [self fail:@"暂时无法保存演示凭据。" error:error];
    [self.defaults setObject:@{@"phone" : phone, @"salt" : salt, @"digest" : digest} forKey:TYAccountKey];
    [self establishSession];
    return YES;
}
- (BOOL)loginPhone:(NSString *)phone code:(NSString *)code error:(NSError **)error {
    phone = [self normalizedPhone:phone];
    if (![[self account][@"phone"] isEqualToString:phone])
        return [self fail:@"该手机号未在本机注册。" error:error];
    if (![self checkCode:code phone:phone registering:NO error:error])
        return NO;
    [self establishSession];
    return YES;
}
- (BOOL)loginPhone:(NSString *)phone password:(NSString *)password error:(NSError **)error {
    if ([self.passwordRetryAt timeIntervalSinceNow] > 0)
        return [self fail:@"尝试次数过多，请等待 30 秒或改用演示验证码登录。" error:error];
    NSDictionary *account = [self account];
    NSData *digest = nil;
    if ([account[@"phone"] isEqualToString:[self normalizedPhone:phone]] && password.length <= 64 &&
        [account[@"salt"] isKindOfClass:NSData.class])
        digest = [self digestForPassword:password salt:account[@"salt"]];
    NSData *stored = account[@"digest"];
    unsigned char difference = 0;
    if (digest.length == 32 && stored.length == 32) {
        const unsigned char *a = digest.bytes, *b = stored.bytes;
        for (NSUInteger i = 0; i < 32; i++)
            difference |= a[i] ^ b[i];
        if (!difference) {
            [self establishSession];
            return YES;
        }
    }
    if (++self.passwordFailures >= 5) {
        self.passwordRetryAt = [NSDate dateWithTimeIntervalSinceNow:30];
        self.passwordFailures = 0;
    }
    return [self fail:@"手机号或演示密码不正确。" error:error];
}
- (void)establishSession {
    [self logout];
    self.authenticated = YES;
}
- (void)logout {
    self.authenticated = NO;
    self.pendingPhone = nil;
    self.pendingCode = nil;
    self.issuedAt = nil;
    self.codeAttempts = 0;
    self.passwordFailures = 0;
    self.passwordRetryAt = nil;
}
- (void)removeAccount {
    [self logout];
    [self.defaults removeObjectForKey:TYAccountKey];
}
@end
