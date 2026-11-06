#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface TYRouter : NSObject
+ (UIViewController *)controllerForRoute:(NSString *)route identifier:(nullable NSString *)identifier;
@end
NS_ASSUME_NONNULL_END
