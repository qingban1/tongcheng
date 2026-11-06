#import <UIKit/UIKit.h>
@interface TYRootViewController : UIViewController
- (void)selectIndex:(NSInteger)index;
- (void)requireAuthenticationForTitle:(NSString *)title action:(void (^)(void))action;
- (void)returnToGuestSquare;
@end
