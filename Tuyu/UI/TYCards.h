#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface TYCards : NSObject
+ (UIView *)tappable:(UIView *)content label:(NSString *)label action:(void (^)(void))action;
+ (UIView *)menuRow:(NSString *)title
           subtitle:(NSString *)subtitle
             symbol:(NSString *)symbol
             action:(void (^)(void))action;
+ (UIView *)post:(NSDictionary *)post action:(void (^)(void))action;
+ (UIView *)activity:(NSDictionary *)activity action:(void (^)(void))action;
+ (UIView *)trip:(NSDictionary *)trip action:(void (^)(void))action;
@end
NS_ASSUME_NONNULL_END
