#import "TYBaseViewController.h"
#import "TYRouter.h"
#import "TYRootViewController.h"
@interface TYBaseViewController ()
@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) UIStackView *bodyStack;
@end
@implementation TYBaseViewController
- (TYLocalStore *)store {
    return TYLocalStore.sharedStore;
}
- (void)loadView {
    self.view = [TYGradientView new];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.accessibilityIdentifier = NSStringFromClass(self.class);
    self.scrollView = [UIScrollView new];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [self.view addSubview:self.scrollView];
    self.bodyStack = TYDesign.verticalStack;
    self.bodyStack.spacing = 14;
    [self.scrollView addSubview:self.bodyStack];
    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.keyboardLayoutGuide.topAnchor],
        [self.bodyStack.topAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.topAnchor
                                                 constant:14],
        [self.bodyStack.bottomAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.bottomAnchor
                                                    constant:-24],
        [self.bodyStack.leadingAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.leadingAnchor
                                                     constant:20],
        [self.bodyStack.trailingAnchor
            constraintEqualToAnchor:self.scrollView.contentLayoutGuide.trailingAnchor
                           constant:-20],
        [self.bodyStack.widthAnchor constraintEqualToAnchor:self.scrollView.frameLayoutGuide.widthAnchor
                                                   constant:-40]
    ]];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self renderContent];
}
- (void)renderContent {
    for (UIView *v in self.bodyStack.arrangedSubviews) {
        [self.bodyStack removeArrangedSubview:v];
        [v removeFromSuperview];
    }
}
- (void)add:(UIView *)view {
    [self.bodyStack addArrangedSubview:view];
}
- (void)addTitle:(NSString *)title
        subtitle:(NSString *)subtitle
     actionTitle:(NSString *)actionTitle
          action:(void (^)(void))action {
    UILabel *eyebrow = [TYDesign label:subtitle size:11 weight:UIFontWeightRegular];
    eyebrow.textColor = TYDesign.muted;
    UILabel *h = [TYDesign label:title size:28 weight:UIFontWeightBold];
    UIStackView *titles = TYDesign.verticalStack;
    titles.spacing = 5;
    [titles addArrangedSubview:eyebrow];
    [titles addArrangedSubview:h];
    UIStackView *r = [[UIStackView alloc] initWithArrangedSubviews:@[ titles ]];
    r.translatesAutoresizingMaskIntoConstraints = NO;
    r.axis = UILayoutConstraintAxisHorizontal;
    r.alignment = UIStackViewAlignmentCenter;
    r.spacing = 10;
    if (actionTitle) {
        TYActionButton *b = [TYActionButton new];
        b.actionHandler = action;
        UIButtonConfiguration *config = UIButtonConfiguration.plainButtonConfiguration;
        NSDictionary *symbols =
            @{@"＋" : @"plus", @"设置" : @"gearshape", @"说明" : @"shield", @"护照" : @"calendar"};
        NSString *symbol = symbols[actionTitle];
        if (symbol) {
            config.image = [UIImage systemImageNamed:symbol];
            config.preferredSymbolConfigurationForImage =
                [UIImageSymbolConfiguration configurationWithPointSize:22 weight:UIImageSymbolWeightRegular];
        } else
            config.title = actionTitle;
        config.baseForegroundColor = TYDesign.ink;
        config.contentInsets = NSDirectionalEdgeInsetsMake(0, 0, 0, 0);
        b.configuration = config;
        b.backgroundColor = [[TYDesign color:@"FFD5B7"] colorWithAlphaComponent:.7];
        b.layer.cornerRadius = 22;
        b.accessibilityLabel = [actionTitle isEqual:@"＋"] ? @"新建" : actionTitle;
        [b.widthAnchor constraintEqualToConstant:44].active = YES;
        [b.heightAnchor constraintEqualToConstant:44].active = YES;
        [r addArrangedSubview:b];
    }
    [self add:r];
}
- (void)addBackTitle:(NSString *)title {
    __weak typeof(self) weakSelf = self;
    TYActionButton *back = [TYDesign button:@"‹"
                                      style:@"outline"
                                     action:^{
                                         [weakSelf.navigationController popViewControllerAnimated:YES];
                                     }];
    back.accessibilityLabel = @"返回";
    [back.widthAnchor constraintEqualToConstant:44].active = YES;
    UILabel *h = [TYDesign label:title size:20 weight:UIFontWeightSemibold];
    UIStackView *r = [[UIStackView alloc] initWithArrangedSubviews:@[ back, h ]];
    r.axis = UILayoutConstraintAxisHorizontal;
    r.spacing = 12;
    r.alignment = UIStackViewAlignmentCenter;
    [self add:r];
}
- (void)addText:(NSString *)text {
    [self add:[TYDesign label:text size:14 weight:UIFontWeightRegular]];
}
- (void)addNote:(NSString *)text {
    UILabel *l = [TYDesign label:text size:12 weight:UIFontWeightRegular];
    l.textColor = TYDesign.muted;
    UIView *v = [TYDesign card:@[ l ] dark:NO];
    v.layer.cornerRadius = 13;
    v.backgroundColor = [[TYDesign color:@"E8B48B"] colorWithAlphaComponent:.6];
    [self add:v];
}
- (void)addSection:(NSString *)text {
    UILabel *l = [TYDesign label:text size:18 weight:UIFontWeightSemibold];
    [self add:l];
    [self.bodyStack setCustomSpacing:14 afterView:l];
}
- (void)addButton:(NSString *)title style:(NSString *)style action:(void (^)(void))action {
    [self add:[TYDesign button:title style:style action:action]];
}
- (void)addChips:(NSArray<NSString *> *)titles
        selected:(NSString *)selected
          action:(void (^)(NSString *))action {
    UIScrollView *sc = [UIScrollView new];
    sc.translatesAutoresizingMaskIntoConstraints = NO;
    sc.showsHorizontalScrollIndicator = NO;
    UIStackView *r = [UIStackView new];
    r.translatesAutoresizingMaskIntoConstraints = NO;
    r.axis = UILayoutConstraintAxisHorizontal;
    r.spacing = 8;
    for (NSString *t in titles) {
        TYActionButton *b = [TYDesign button:t
                                       style:[t isEqual:selected] ? @"" : @"outline"
                                      action:^{
                                          action(t);
                                      }];
        for (NSLayoutConstraint *constraint in b.constraints)
            if (constraint.firstAttribute == NSLayoutAttributeHeight)
                constraint.constant = 44;
        b.layer.cornerRadius = 22;
        UIButtonConfiguration *config = b.configuration;
        config.titleTextAttributesTransformer = ^NSDictionary *(NSDictionary *attrs) {
            NSMutableDictionary *d = [attrs mutableCopy];
            d[NSFontAttributeName] = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
            return d;
        };
        b.configuration = config;
        b.accessibilityTraits |= [t isEqual:selected] ? UIAccessibilityTraitSelected : 0;
        [r addArrangedSubview:b];
    }
    [sc addSubview:r];
    [NSLayoutConstraint activateConstraints:@[
        [sc.heightAnchor constraintEqualToConstant:44],
        [r.leadingAnchor constraintEqualToAnchor:sc.contentLayoutGuide.leadingAnchor],
        [r.trailingAnchor constraintEqualToAnchor:sc.contentLayoutGuide.trailingAnchor],
        [r.topAnchor constraintEqualToAnchor:sc.contentLayoutGuide.topAnchor],
        [r.bottomAnchor constraintEqualToAnchor:sc.contentLayoutGuide.bottomAnchor],
        [r.heightAnchor constraintEqualToAnchor:sc.frameLayoutGuide.heightAnchor]
    ]];
    [self add:sc];
}
- (void)pushRoute:(NSString *)route identifier:(NSString *)identifier {
    UIViewController *v = [TYRouter controllerForRoute:route identifier:identifier];
    [self.navigationController pushViewController:v animated:YES];
}
- (void)selectTab:(NSInteger)index {
    UIViewController *v = self;
    while (v.parentViewController)
        v = v.parentViewController;
    if ([v isKindOfClass:TYRootViewController.class])
        [(TYRootViewController *)v selectIndex:index];
}
- (TYRootViewController *)rootContainer {
    UIViewController *root = self;
    while (root.parentViewController)
        root = root.parentViewController;
    return [root isKindOfClass:TYRootViewController.class] ? (TYRootViewController *)root : nil;
}
- (void)requireLoginForTitle:(NSString *)title action:(void (^)(void))action {
    [[self rootContainer] requireAuthenticationForTitle:title action:action];
}
- (void)returnToGuestSquare {
    [[self rootContainer] returnToGuestSquare];
}
- (void)showError:(NSError *)error {
    [self showMessage:error.localizedDescription ?: @"暂时无法完成操作，请重试。"];
}
- (void)showMessage:(NSString *)text {
    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"同城徒遇"
                                                               message:text
                                                        preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:a animated:YES completion:nil];
}
- (void)confirm:(NSString *)title text:(NSString *)text action:(void (^)(void))action {
    UIAlertController *a = [UIAlertController alertControllerWithTitle:title
                                                               message:text
                                                        preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"暂不操作" style:UIAlertActionStyleCancel handler:nil]];
    [a addAction:[UIAlertAction actionWithTitle:@"确认"
                                          style:UIAlertActionStyleDestructive
                                        handler:^(UIAlertAction *item) {
                                            action();
                                        }]];
    [self presentViewController:a animated:YES completion:nil];
}
@end
