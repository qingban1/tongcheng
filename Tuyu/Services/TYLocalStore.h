#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
FOUNDATION_EXPORT NSNotificationName const TYStoreDidChangeNotification;
@interface TYLocalStore : NSObject
@property(class, nonatomic, readonly) TYLocalStore *sharedStore;
@property(nonatomic, readonly) NSMutableDictionary *state;
@property(nonatomic, readonly, nullable) NSError *lastSaveError;
- (instancetype)initWithDefaults:(NSUserDefaults *)defaults;
- (void)commit;
- (void)resetDataKeepingExamples:(BOOL)keepExamples;
- (NSArray<NSMutableDictionary *> *)items:(NSString *)key;
- (nullable NSMutableDictionary *)item:(NSString *)identifier in:(NSString *)key;
- (NSDictionary *)statistics;
- (NSString *)statusForActivity:(NSDictionary *)activity;
- (NSString *)applicationStatus:(NSString *)activityId;
- (BOOL)canAccessActivity:(NSDictionary *)activity;
- (BOOL)applyToActivity:(NSString *)identifier values:(NSDictionary *)values error:(NSError **)error;
- (BOOL)setApplication:(NSString *)identifier status:(NSString *)status error:(NSError **)error;
- (nullable NSString *)saveActivity:(NSDictionary *)values
                          editingId:(nullable NSString *)editingId
                              error:(NSError **)error;
- (void)moderateActivity:(NSString *)identifier approved:(BOOL)approved;
- (void)cancelActivity:(NSString *)identifier reason:(NSString *)reason;
- (BOOL)decideRequest:(NSString *)requestId approved:(BOOL)approved error:(NSError **)error;
- (void)deleteTrip:(NSString *)identifier;
- (nullable NSString *)publishDraftWithError:(NSError **)error;
- (void)moderatePost:(NSString *)identifier status:(NSString *)status;
- (void)toggleIdentifier:(NSString *)identifier in:(NSString *)key;
- (BOOL)containsIdentifier:(NSString *)identifier in:(NSString *)key;
- (void)addMessage:(NSString *)text
              type:(NSString *)type
             route:(NSString *)route
          objectId:(nullable NSString *)objectId;
+ (NSString *)identifier;
+ (NSString *)dateText:(NSNumber *)timestamp;
+ (NSString *)durationText:(NSTimeInterval)seconds;
@end
NS_ASSUME_NONNULL_END
