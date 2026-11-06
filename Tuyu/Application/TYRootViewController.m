#import "TYRootViewController.h"
#import "TYRouter.h"
#import "TYDesign.h"
#import "TYAuthViewController.h"
#import "TYLocalAuthService.h"
#import "TYTrackingService.h"
@interface TYRootViewController () <UINavigationControllerDelegate>
@property(nonatomic, strong) UIView *container;
@property(nonatomic, strong) NSArray<UINavigationController *> *navigationControllers;
@property(nonatomic, strong) NSMutableArray<TYActionButton *> *buttons;
@property(nonatomic) NSInteger currentIndex;
@property(nonatomic, strong) UIView *bar;
@property(nonatomic, strong) NSLayoutConstraint *tabContentBottom;
@property(nonatomic, strong) NSLayoutConstraint *fullContentBottom;
@end
@implementation TYRootViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view = [TYGradientView new];
    self.buttons = [NSMutableArray new];
    UIView *bar = [UIView new];
    bar.translatesAutoresizingMaskIntoConstraints = NO;
    self.bar = bar;
    bar.backgroundColor = [TYDesign color:@"FFD6B5"];
    [self.view addSubview:bar];
    self.container = [UIView new];
    self.container.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.container];
    UIStackView *stack = [TYDesign horizontalStack:@[]];
    stack.spacing = 0;
    [bar addSubview:stack];
    [NSLayoutConstraint activateConstraints:@[
        [bar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [bar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [bar.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [bar.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-56],
        [stack.leadingAnchor constraintEqualToAnchor:bar.leadingAnchor constant:10],
        [stack.trailingAnchor constraintEqualToAnchor:bar.trailingAnchor constant:-10],
        [stack.topAnchor constraintEqualToAnchor:bar.topAnchor],
        [stack.heightAnchor constraintEqualToConstant:56],
        [self.container.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.container.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.container.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        (self.tabContentBottom = [self.container.bottomAnchor constraintEqualToAnchor:bar.topAnchor])
    ]];
    NSArray *routes = @[ @"square", @"meet", @"records", @"hike", @"mine" ],
            *titles = @[ @"广场", @"约行", @"记录", @"徒步", @"我的" ],
            *symbols =
                @[ @"square.grid.2x2", @"person.2", @"calendar", @"figure.hiking", @"person.crop.circle" ];
    NSMutableArray *navs = [NSMutableArray new];
    __weak typeof(self) weakSelf = self;
    for (NSInteger i = 0; i < 5; i++) {
        UIViewController *v = [TYRouter controllerForRoute:routes[i] identifier:nil];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:v];
        nav.navigationBarHidden = YES;
        nav.delegate = self;
        [navs addObject:nav];
        TYActionButton *b = [TYActionButton new];
        b.actionHandler = ^{
            [weakSelf selectIndex:i];
        };
        UIButtonConfiguration *c = UIButtonConfiguration.plainButtonConfiguration;
        c.title = titles[i];
        c.image = [UIImage systemImageNamed:symbols[i]];
        c.imagePlacement = NSDirectionalRectEdgeTop;
        c.imagePadding = 3;
        c.baseForegroundColor = [TYDesign color:@"694632"];
        c.preferredSymbolConfigurationForImage =
            [UIImageSymbolConfiguration configurationWithPointSize:21 weight:UIImageSymbolWeightRegular];
        c.contentInsets = NSDirectionalEdgeInsetsMake(7, 0, 3, 0);
        c.titleTextAttributesTransformer = ^NSDictionary *(NSDictionary *a) {
            NSMutableDictionary *d = [a mutableCopy];
            d[NSFontAttributeName] = [UIFont systemFontOfSize:11 weight:UIFontWeightMedium];
            return d;
        };
        b.configuration = c;
        b.accessibilityIdentifier = [@"tab-" stringByAppendingString:routes[i]];
        b.accessibilityLabel = titles[i];
        [self.buttons addObject:b];
        [stack addArrangedSubview:b];
    }
    self.navigationControllers = navs;
    self.currentIndex = -1;
    [self selectIndex:0];
}
- (void)selectIndex:(NSInteger)index {
    if (index < 0 || index >= self.navigationControllers.count)
        return;
    if (index > 0 && !TYLocalAuthService.sharedService.isAuthenticated) {
        NSArray<NSString *> *titles = @[ @"广场", @"约行", @"记录", @"徒步", @"我的" ];
        __weak typeof(self) weakSelf = self;
        [self requireAuthenticationForTitle:titles[index]
                                     action:^{
                                         [weakSelf selectIndex:index];
                                     }];
        return;
    }
    if (self.currentIndex == index) {
        [self.navigationControllers[index] popToRootViewControllerAnimated:YES];
        return;
    }
    if (self.currentIndex >= 0) {
        UIViewController *old = self.navigationControllers[self.currentIndex];
        [old willMoveToParentViewController:nil];
        [old.view removeFromSuperview];
        [old removeFromParentViewController];
    }
    UINavigationController *nav = self.navigationControllers[index];
    [self addChildViewController:nav];
    nav.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.container addSubview:nav.view];
    [NSLayoutConstraint activateConstraints:@[
        [nav.view.topAnchor constraintEqualToAnchor:self.container.topAnchor],
        [nav.view.leadingAnchor constraintEqualToAnchor:self.container.leadingAnchor],
        [nav.view.trailingAnchor constraintEqualToAnchor:self.container.trailingAnchor],
        [nav.view.bottomAnchor constraintEqualToAnchor:self.container.bottomAnchor]
    ]];
    [nav didMoveToParentViewController:self];
    self.currentIndex = index;
    [self updateBarForNavigationController:nav];
    for (NSInteger i = 0; i < self.buttons.count; i++) {
        TYActionButton *b = self.buttons[i];
        UIButtonConfiguration *c = b.configuration;
        c.baseForegroundColor = [TYDesign color:i == index ? @"7B2E0D" : @"694632"];
        b.configuration = c;
        b.accessibilityTraits = UIAccessibilityTraitButton | (i == index ? UIAccessibilityTraitSelected : 0);
    }
}
- (void)requireAuthenticationForTitle:(NSString *)title action:(void (^)(void))action {
    if (TYLocalAuthService.sharedService.isAuthenticated) {
        action();
        return;
    }
    if (self.presentedViewController)
        return;
    TYAuthViewController *auth = [TYAuthViewController new];
    auth.destinationTitle = title;
    auth.modalPresentationStyle = UIModalPresentationFullScreen;
    auth.completion = ^(BOOL authenticated) {
        if (authenticated)
            action();
    };
    [self presentViewController:auth animated:YES completion:nil];
}
- (void)returnToGuestSquare {
    if (TYTrackingService.sharedService.session &&
        ![TYTrackingService.sharedService.session[@"paused"] boolValue])
        [TYTrackingService.sharedService togglePause];
    [TYLocalAuthService.sharedService logout];
    [self selectIndex:0];
    for (UINavigationController *navigation in self.navigationControllers)
        [navigation popToRootViewControllerAnimated:NO];
    if ([self.navigationControllers.firstObject.topViewController
            respondsToSelector:@selector(renderContent)])
        [(TYBaseViewController *)self.navigationControllers.firstObject.topViewController renderContent];
}
- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    if (self.currentIndex >= 0 && navigationController == self.navigationControllers[self.currentIndex])
        [self updateBarForNavigationController:navigationController];
}
- (void)updateBarForNavigationController:(UINavigationController *)nav {
    BOOL hide = nav.viewControllers.count > 1;
    self.bar.hidden = hide;
    if (!self.fullContentBottom)
        self.fullContentBottom = [self.container.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor];
    self.tabContentBottom.active = NO;
    self.fullContentBottom.active = NO;
    if (hide)
        self.fullContentBottom.active = YES;
    else
        self.tabContentBottom.active = YES;
}
@end
