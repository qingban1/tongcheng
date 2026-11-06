#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface TYGradientView : UIView
- (void)applyColors:(NSArray<UIColor *> *)colors;
@end
@interface TYActionButton : UIButton
@property(nonatomic, copy, nullable) void (^actionHandler)(void);
@end
@interface TYDesign : NSObject
+ (UIColor *)color:(NSString *)hex;
+ (UIColor *)ink;
+ (UIColor *)muted;
+ (UIColor *)deep;
+ (UIColor *)cream;
+ (UILabel *)label:(NSString *)text size:(CGFloat)size weight:(UIFontWeight)weight;
+ (TYActionButton *)button:(NSString *)title style:(NSString *)style action:(void (^)(void))action;
+ (UIStackView *)verticalStack;
+ (UIStackView *)horizontalStack:(NSArray<UIView *> *)views;
+ (UIView *)card:(NSArray<UIView *> *)views dark:(BOOL)dark;
+ (UIView *)hero:(NSString *)photo
           title:(NSString *)title
        subtitle:(NSString *)subtitle
           badge:(NSString *)badge;
+ (UIView *)photo:(NSString *)key height:(CGFloat)height;
+ (UIView *)person:(NSString *)name subtitle:(NSString *)subtitle;
+ (UIView *)metrics:(NSDictionary *)trip;
+ (UIView *)mapWithPoints:(nullable NSArray *)points example:(BOOL)example;
+ (void)updateMap:(UIView *)map points:(NSArray *)points;
+ (UIView *)pill:(NSString *)text;
@end
NS_ASSUME_NONNULL_END
