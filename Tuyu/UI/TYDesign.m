#import "TYDesign.h"
#import "TYArtwork.h"
#import "TYLocalStore.h"
#import <QuartzCore/QuartzCore.h>
@implementation TYGradientView
+ (Class)layerClass {
    return CAGradientLayer.class;
}
- (instancetype)init {
    if ((self = [super init])) {
        CAGradientLayer *l = (id)self.layer;
        l.startPoint = CGPointMake(0, 0);
        l.endPoint = CGPointMake(.75, 1);
        [self applyColors:@[
            [TYDesign color:@"FF9252"], [TYDesign color:@"FFAB78"], [TYDesign color:@"F5BD9D"]
        ]];
    }
    return self;
}
- (void)applyColors:(NSArray<UIColor *> *)colors {
    ((CAGradientLayer *)self.layer).locations = colors.count == 3 ? @[ @0, @.38, @1 ] : nil;
    NSMutableArray *c = [NSMutableArray new];
    for (UIColor *v in colors)
        [c addObject:(id)v.CGColor];
    ((CAGradientLayer *)self.layer).colors = c;
}
@end
@implementation TYActionButton
- (instancetype)init {
    if ((self = [super init])) {
        [self addTarget:self action:@selector(invokeAction) forControlEvents:UIControlEventTouchUpInside];
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}
- (void)invokeAction {
    if (self.actionHandler)
        self.actionHandler();
}
@end
@interface TYContourView : UIView
@property(nonatomic, copy) NSArray *points;
@property(nonatomic) BOOL example;
@end
@implementation TYContourView
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [TYDesign color:@"C4C99F"].CGColor);
    CGContextFillRect(ctx, rect);
    CGFloat w = rect.size.width, h = rect.size.height;
    [[TYDesign color:@"8B9A70"] setStroke];
    for (NSInteger i = -3; i < 10; i++) {
        UIBezierPath *p = [UIBezierPath bezierPath];
        [p moveToPoint:CGPointMake(-30, i * 40)];
        [p addCurveToPoint:CGPointMake(w + 30, i * 40 + 70)
             controlPoint1:CGPointMake(w * .25, i * 40 - 80)
             controlPoint2:CGPointMake(w * .65, i * 40 + 120)];
        p.lineWidth = .8;
        [p stroke];
    }
    NSMutableArray<NSValue *> *nodes = [NSMutableArray new];
    if (self.example) {
        NSArray *a = @[
            @[ @40, @250 ], @[ @100, @190 ], @[ @90, @130 ], @[ @160, @100 ], @[ @190, @47 ], @[ @250, @64 ],
            @[ @280, @140 ], @[ @234, @181 ]
        ];
        for (NSArray *p in a)
            [nodes addObject:[NSValue valueWithCGPoint:CGPointMake([p[0] doubleValue] / 360 * w,
                                                                   [p[1] doubleValue] / 280 * h)]];
    } else if (self.points.count) {
        double minLat = 90, maxLat = -90, minLon = 180, maxLon = -180;
        for (NSDictionary *p in self.points) {
            double lat = [p[@"latitude"] doubleValue], lon = [p[@"longitude"] doubleValue];
            minLat = MIN(lat, minLat);
            maxLat = MAX(lat, maxLat);
            minLon = MIN(lon, minLon);
            maxLon = MAX(lon, maxLon);
        }
        for (NSDictionary *p in self.points) {
            CGFloat x = 25 +
                        ([p[@"longitude"] doubleValue] - minLon) / MAX(.0001, maxLon - minLon) * (w - 50),
                    y = h - 25 -
                        ([p[@"latitude"] doubleValue] - minLat) / MAX(.0001, maxLat - minLat) * (h - 50);
            [nodes addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
        }
    }
    UIBezierPath *path = [UIBezierPath bezierPath];
    for (NSUInteger i = 0; i < nodes.count; i++) {
        CGPoint p = nodes[i].CGPointValue;
        BOOL broken = (!self.example && i < self.points.count && [self.points[i][@"break"] boolValue]);
        if (i == 0 || broken)
            [path moveToPoint:p];
        else
            [path addLineToPoint:p];
    }
    path.lineWidth = 11;
    [[TYDesign cream] setStroke];
    [path stroke];
    path.lineWidth = 4;
    [[TYDesign color:@"9A3E0B"] setStroke];
    [path stroke];
    if (nodes.count) {
        CGPoint p = nodes.lastObject.CGPointValue;
        UIBezierPath *dot = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(p.x - 8, p.y - 8, 16, 16)];
        [[TYDesign color:@"FF9252"] setFill];
        [dot fill];
        [[TYDesign cream] setStroke];
        dot.lineWidth = 3;
        [dot stroke];
    }
}
@end
@implementation TYDesign
+ (UIColor *)color:(NSString *)hex {
    unsigned int n = 0;
    [[NSScanner scannerWithString:hex] scanHexInt:&n];
    return [UIColor colorWithRed:((n >> 16) & 255) / 255.
                           green:((n >> 8) & 255) / 255.
                            blue:(n & 255) / 255.
                           alpha:1];
}
+ (UIColor *)ink {
    return [self color:@"292124"];
}
+ (UIColor *)muted {
    return [self color:@"694632"];
}
+ (UIColor *)deep {
    return [self color:@"303E34"];
}
+ (UIColor *)cream {
    return [self color:@"FFE5C7"];
}
+ (UILabel *)label:(NSString *)text size:(CGFloat)size weight:(UIFontWeight)weight {
    UILabel *l = [UILabel new];
    l.translatesAutoresizingMaskIntoConstraints = NO;
    l.text = text;
    l.numberOfLines = 0;
    l.font = [[UIFontMetrics metricsForTextStyle:UIFontTextStyleBody]
        scaledFontForFont:[UIFont systemFontOfSize:size weight:weight]];
    l.adjustsFontForContentSizeCategory = YES;
    l.textColor = self.ink;
    [l setContentCompressionResistancePriority:UILayoutPriorityRequired
                                       forAxis:UILayoutConstraintAxisVertical];
    return l;
}
+ (TYActionButton *)button:(NSString *)title style:(NSString *)style action:(void (^)(void))action {
    TYActionButton *b = [TYActionButton new];
    b.actionHandler = action;
    b.layer.cornerRadius = 16;
    b.clipsToBounds = YES;
    UIButtonConfiguration *c = UIButtonConfiguration.plainButtonConfiguration;
    c.title = title;
    c.contentInsets = NSDirectionalEdgeInsetsMake(14, 12, 14, 12);
    c.baseForegroundColor = self.cream;
    c.titleTextAttributesTransformer = ^NSDictionary *(NSDictionary *attributes) {
        NSMutableDictionary *a = [attributes mutableCopy];
        a[NSFontAttributeName] = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
        return a;
    };
    b.configuration = c;
    b.titleLabel.numberOfLines = 0;
    b.accessibilityLabel = title;
    b.backgroundColor = self.deep;
    if ([style isEqual:@"outline"]) {
        b.backgroundColor = UIColor.clearColor;
        b.layer.borderWidth = 1;
        b.layer.borderColor = [self color:@"9A6347"].CGColor;
        c.baseForegroundColor = self.ink;
    }
    if ([style isEqual:@"danger"]) {
        b.backgroundColor = [self color:@"F0C1A6"];
        c.baseForegroundColor = [self color:@"8E2030"];
    }
    if ([style isEqual:@"gradient"]) {
        TYGradientView *g = [TYGradientView new];
        g.translatesAutoresizingMaskIntoConstraints = NO;
        [g applyColors:@[ [self color:@"FFA671"], [self color:@"FF7BAA"] ]];
        g.userInteractionEnabled = NO;
        [b insertSubview:g atIndex:0];
        [NSLayoutConstraint activateConstraints:@[
            [g.leadingAnchor constraintEqualToAnchor:b.leadingAnchor],
            [g.trailingAnchor constraintEqualToAnchor:b.trailingAnchor],
            [g.topAnchor constraintEqualToAnchor:b.topAnchor],
            [g.bottomAnchor constraintEqualToAnchor:b.bottomAnchor]
        ]];
        c.baseForegroundColor = self.ink;
    }
    BOOL compact = [style isEqual:@"link"] || [style isEqual:@"soft"];
    if (compact) {
        b.backgroundColor = [style isEqual:@"soft"] ? [self color:@"FFD8B9"] : UIColor.clearColor;
        c.baseForegroundColor = self.muted;
        b.layer.cornerRadius = [style isEqual:@"soft"] ? 22 : 0;
        c.titleTextAttributesTransformer = ^NSDictionary *(NSDictionary *attributes) {
            NSMutableDictionary *a = [attributes mutableCopy];
            a[NSFontAttributeName] = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
            return a;
        };
    }
    b.configuration = c;
    [b.heightAnchor constraintGreaterThanOrEqualToConstant:compact ? 44 : 52].active = YES;
    return b;
}
+ (UIStackView *)verticalStack {
    UIStackView *s = [UIStackView new];
    s.translatesAutoresizingMaskIntoConstraints = NO;
    s.axis = UILayoutConstraintAxisVertical;
    s.spacing = 12;
    return s;
}
+ (UIStackView *)horizontalStack:(NSArray<UIView *> *)views {
    UIStackView *s = [[UIStackView alloc] initWithArrangedSubviews:views];
    s.translatesAutoresizingMaskIntoConstraints = NO;
    s.axis = UILayoutConstraintAxisHorizontal;
    s.spacing = 10;
    s.distribution = UIStackViewDistributionFillEqually;
    s.alignment = UIStackViewAlignmentFill;
    return s;
}
+ (void)makeLight:(UIView *)view {
    if ([view.accessibilityIdentifier isEqual:@"pill"])
        return;
    if ([view isKindOfClass:UIButton.class])
        return;
    if ([view isKindOfClass:UILabel.class])
        ((UILabel *)view).textColor = self.cream;
    for (UIView *child in view.subviews)
        [self makeLight:child];
}
+ (UIView *)card:(NSArray<UIView *> *)views dark:(BOOL)dark {
    UIView *v = [UIView new];
    v.translatesAutoresizingMaskIntoConstraints = NO;
    v.backgroundColor = dark ? self.deep : [self color:@"FFDABD"];
    v.layer.cornerRadius = 22;
    v.layer.borderWidth = dark ? 0 : 1;
    v.layer.borderColor = [self color:@"B57951"].CGColor;
    UIStackView *s = self.verticalStack;
    for (UIView *child in views) {
        if (dark)
            [self makeLight:child];
        [s addArrangedSubview:child];
    }
    [v addSubview:s];
    [NSLayoutConstraint activateConstraints:@[
        [s.topAnchor constraintEqualToAnchor:v.topAnchor constant:18],
        [s.bottomAnchor constraintEqualToAnchor:v.bottomAnchor constant:-18],
        [s.leadingAnchor constraintEqualToAnchor:v.leadingAnchor constant:18],
        [s.trailingAnchor constraintEqualToAnchor:v.trailingAnchor constant:-18]
    ]];
    return v;
}
+ (UIView *)photo:(NSString *)key height:(CGFloat)height {
    UIImageView *v = [[UIImageView alloc] initWithImage:[TYArtwork imageForKey:key]];
    v.translatesAutoresizingMaskIntoConstraints = NO;
    v.contentMode = UIViewContentModeScaleAspectFill;
    v.clipsToBounds = YES;
    v.layer.cornerRadius = 16;
    v.isAccessibilityElement = YES;
    v.accessibilityLabel = @"户外摄影示意，并非路线实景";
    [v.heightAnchor constraintEqualToConstant:height].active = YES;
    return v;
}
+ (UIView *)hero:(NSString *)photo
           title:(NSString *)title
        subtitle:(NSString *)subtitle
           badge:(NSString *)badge {
    UIView *v = [UIView new];
    v.translatesAutoresizingMaskIntoConstraints = NO;
    v.layer.cornerRadius = 25;
    v.clipsToBounds = YES;
    UIView *image = [self photo:photo height:310];
    image.layer.cornerRadius = 0;
    [v addSubview:image];
    TYGradientView *shade = [TYGradientView new];
    shade.translatesAutoresizingMaskIntoConstraints = NO;
    [shade applyColors:@[
        UIColor.clearColor, UIColor.clearColor, [[self color:@"14231C"] colorWithAlphaComponent:.92]
    ]];
    ((CAGradientLayer *)shade.layer).locations = @[ @0, @.3, @1 ];
    [v addSubview:shade];
    UILabel *h = [self label:title size:29 weight:UIFontWeightBold];
    h.textColor = [self color:@"FFF1DC"];
    UILabel *sub = [self label:subtitle size:12 weight:UIFontWeightRegular];
    sub.textColor = h.textColor;
    UIStackView *s = self.verticalStack;
    [s addArrangedSubview:h];
    [s addArrangedSubview:sub];
    [v addSubview:s];
    UIView *p = [self pill:badge];
    [v addSubview:p];
    [NSLayoutConstraint activateConstraints:@[
        [v.heightAnchor constraintEqualToConstant:310], [image.topAnchor constraintEqualToAnchor:v.topAnchor],
        [image.bottomAnchor constraintEqualToAnchor:v.bottomAnchor],
        [image.leadingAnchor constraintEqualToAnchor:v.leadingAnchor],
        [image.trailingAnchor constraintEqualToAnchor:v.trailingAnchor],
        [shade.topAnchor constraintEqualToAnchor:v.topAnchor],
        [shade.bottomAnchor constraintEqualToAnchor:v.bottomAnchor],
        [shade.leadingAnchor constraintEqualToAnchor:v.leadingAnchor],
        [shade.trailingAnchor constraintEqualToAnchor:v.trailingAnchor],
        [s.leadingAnchor constraintEqualToAnchor:v.leadingAnchor constant:22],
        [s.trailingAnchor constraintEqualToAnchor:v.trailingAnchor constant:-22],
        [s.bottomAnchor constraintEqualToAnchor:v.bottomAnchor constant:-22],
        [p.topAnchor constraintEqualToAnchor:v.topAnchor constant:17],
        [p.leadingAnchor constraintEqualToAnchor:v.leadingAnchor constant:17],
        [p.trailingAnchor constraintLessThanOrEqualToAnchor:v.trailingAnchor constant:-17]
    ]];
    return v;
}
+ (UIView *)pill:(NSString *)text {
    UILabel *l = [self label:text size:11 weight:UIFontWeightMedium];
    l.textColor = [self color:@"553624"];
    UIView *v = [UIView new];
    v.translatesAutoresizingMaskIntoConstraints = NO;
    v.accessibilityIdentifier = @"pill";
    v.backgroundColor = [self color:@"FFE4C8"];
    v.layer.cornerRadius = 13;
    [v addSubview:l];
    [NSLayoutConstraint activateConstraints:@[
        [l.topAnchor constraintEqualToAnchor:v.topAnchor constant:6],
        [l.bottomAnchor constraintEqualToAnchor:v.bottomAnchor constant:-6],
        [l.leadingAnchor constraintEqualToAnchor:v.leadingAnchor constant:10],
        [l.trailingAnchor constraintEqualToAnchor:v.trailingAnchor constant:-10]
    ]];
    return v;
}
+ (UIView *)person:(NSString *)name subtitle:(NSString *)subtitle {
    UILabel *avatar = [self label:name.length ? [name substringFromIndex:name.length - 1] : @"遇"
                             size:14
                           weight:UIFontWeightMedium];
    avatar.textAlignment = NSTextAlignmentCenter;
    avatar.textColor = self.cream;
    avatar.backgroundColor = self.deep;
    avatar.layer.cornerRadius = 18;
    avatar.clipsToBounds = YES;
    [avatar.widthAnchor constraintEqualToConstant:36].active = YES;
    [avatar.heightAnchor constraintEqualToConstant:36].active = YES;
    UIStackView *s = self.verticalStack;
    s.spacing = 4;
    [s addArrangedSubview:[self label:name size:13 weight:UIFontWeightSemibold]];
    UILabel *l = [self label:subtitle size:11 weight:UIFontWeightRegular];
    l.textColor = self.muted;
    [s addArrangedSubview:l];
    UIStackView *r = [[UIStackView alloc] initWithArrangedSubviews:@[ avatar, s ]];
    r.translatesAutoresizingMaskIntoConstraints = NO;
    r.axis = UILayoutConstraintAxisHorizontal;
    r.spacing = 10;
    r.alignment = UIStackViewAlignmentCenter;
    return r;
}
+ (UIView *)metrics:(NSDictionary *)t {
    NSArray *values = @[
        t[@"distance"] ? [NSString stringWithFormat:@"%.2f", [t[@"distance"] doubleValue]] : @"未记录",
        [TYLocalStore durationText:[t[@"seconds"] doubleValue]],
        [t[@"mode"] isEqual:@"仅计时"] ? @"计时" : @"轨迹"
    ];
    NSArray *labels = @[
        t[@"distance"] ? @"记录距离 km" : @"未采集距离", @"有效用时",
        [t[@"sample"] boolValue] ? @"示例记录" : @"本机记录"
    ];
    NSMutableArray *a = [NSMutableArray new];
    for (NSInteger i = 0; i < 3; i++) {
        UIStackView *s = self.verticalStack;
        s.spacing = 5;
        [s addArrangedSubview:[self label:values[i] size:i == 1 ? 18 : 23 weight:UIFontWeightSemibold]];
        UILabel *l = [self label:labels[i] size:11 weight:UIFontWeightRegular];
        l.textColor = self.muted;
        [s addArrangedSubview:l];
        [a addObject:s];
    }
    return [self horizontalStack:a];
}
+ (void)updateMap:(UIView *)map points:(NSArray *)points {
    if ([map isKindOfClass:TYContourView.class]) {
        ((TYContourView *)map).points = points;
        [map setNeedsDisplay];
    }
}
+ (UIView *)mapWithPoints:(NSArray *)points example:(BOOL)example {
    TYContourView *v = [TYContourView new];
    v.translatesAutoresizingMaskIntoConstraints = NO;
    v.points = points ?: @[];
    v.example = example;
    v.layer.cornerRadius = 23;
    v.clipsToBounds = YES;
    v.isAccessibilityElement = YES;
    v.accessibilityLabel = example ? @"示例轨迹，不能用于导航" : @"记录轨迹示意，不是导航地图";
    [v.heightAnchor constraintEqualToConstant:275].active = YES;
    UIView *p = [self pill:example ? @"示例轨迹 · 非导航地图" : @"本机轨迹 · 非导航地图"];
    [v addSubview:p];
    [NSLayoutConstraint activateConstraints:@[
        [p.topAnchor constraintEqualToAnchor:v.topAnchor constant:15],
        [p.leadingAnchor constraintEqualToAnchor:v.leadingAnchor constant:15]
    ]];
    return v;
}
@end
