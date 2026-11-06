#import <UIKit/UIKit.h>
#import "TYDesign.h"
#import "TYLocalStore.h"
NS_ASSUME_NONNULL_BEGIN
@interface TYBaseViewController : UIViewController
@property(nonatomic, strong, readonly) UIScrollView *scrollView;
@property(nonatomic, strong, readonly) UIStackView *bodyStack;
@property(nonatomic, readonly) TYLocalStore *store;
@property(nonatomic) BOOL isRootPage;
- (void)renderContent;
- (void)add:(UIView *)view;
- (void)addTitle:(NSString *)title
        subtitle:(NSString *)subtitle
     actionTitle:(nullable NSString *)actionTitle
          action:(nullable void (^)(void))action;
- (void)addBackTitle:(NSString *)title;
- (void)addText:(NSString *)text;
- (void)addNote:(NSString *)text;
- (void)addSection:(NSString *)text;
- (void)addButton:(NSString *)title style:(NSString *)style action:(void (^)(void))action;
- (void)addChips:(NSArray<NSString *> *)titles
        selected:(NSString *)selected
          action:(void (^)(NSString *title))action;
- (void)pushRoute:(NSString *)route identifier:(nullable NSString *)identifier;
- (void)selectTab:(NSInteger)index;
- (void)requireLoginForTitle:(NSString *)title action:(void (^)(void))action;
- (void)returnToGuestSquare;
- (void)showError:(nullable NSError *)error;
- (void)showMessage:(NSString *)text;
- (void)confirm:(NSString *)title text:(NSString *)text action:(void (^)(void))action;
@end
NS_ASSUME_NONNULL_END
