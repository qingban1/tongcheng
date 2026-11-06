#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface TYLocalAuthService : NSObject
@property(class, nonatomic, readonly) TYLocalAuthService *sharedService;
@property(nonatomic, readonly, getter=isAuthenticated) BOOL authenticated;
@property(nonatomic, readonly) BOOL hasAccount;
@property(nonatomic, copy, readonly, nullable) NSString *maskedPhone;
- (instancetype)initWithDefaults:(NSUserDefaults *)defaults;
- (nullable NSString *)issueDemoCodeForPhone:(NSString *)phone
                                 registering:(BOOL)registering
                                       error:(NSError **)error;
- (BOOL)registerPhone:(NSString *)phone
                 code:(NSString *)code
             password:(NSString *)password
                error:(NSError **)error;
- (BOOL)loginPhone:(NSString *)phone code:(NSString *)code error:(NSError **)error;
- (BOOL)loginPhone:(NSString *)phone password:(NSString *)password error:(NSError **)error;
- (void)logout;
- (void)removeAccount;
@end
NS_ASSUME_NONNULL_END
