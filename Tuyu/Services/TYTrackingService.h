#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
FOUNDATION_EXPORT NSNotificationName const TYTrackingDidTickNotification;
@interface TYTrackingService : NSObject
@property(class, nonatomic, readonly) TYTrackingService *sharedService;
@property(nonatomic, readonly, nullable) NSMutableDictionary *session;
@property(nonatomic, readonly) NSTimeInterval elapsedSeconds;
@property(nonatomic, copy, readonly) NSString *locationStatus;
- (void)startMode:(NSString *)mode activityId:(nullable NSString *)activityId;
- (void)togglePause;
- (void)resume;
- (nullable NSString *)finish;
- (void)persist;
- (void)discard;
@end
NS_ASSUME_NONNULL_END
