#import "TYCards.h"
#import "TYDesign.h"
#import "TYLocalStore.h"
@implementation TYCards
+ (UIView *)menuRow:(NSString *)title
           subtitle:(NSString *)subtitle
             symbol:(NSString *)symbol
             action:(void (^)(void))action {
    UIImageView *glyph = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:symbol]];
    glyph.translatesAutoresizingMaskIntoConstraints = NO;
    glyph.tintColor = TYDesign.muted;
    glyph.contentMode = UIViewContentModeScaleAspectFit;
    [glyph.widthAnchor constraintEqualToConstant:20].active = YES;
    [glyph.heightAnchor constraintEqualToConstant:20].active = YES;
    UIStackView *labels = TYDesign.verticalStack;
    labels.spacing = 4;
    [labels addArrangedSubview:[TYDesign label:title size:14 weight:UIFontWeightMedium]];
    if (subtitle.length) {
        UILabel *desc = [TYDesign label:subtitle size:12 weight:UIFontWeightRegular];
        desc.textColor = TYDesign.muted;
        [labels addArrangedSubview:desc];
    }
    UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"chevron.right"]];
    arrow.translatesAutoresizingMaskIntoConstraints = NO;
    arrow.tintColor = TYDesign.muted;
    arrow.contentMode = UIViewContentModeScaleAspectFit;
    [arrow.widthAnchor constraintEqualToConstant:14].active = YES;
    [arrow.heightAnchor constraintEqualToConstant:14].active = YES;
    UIStackView *row = [[UIStackView alloc] initWithArrangedSubviews:@[ glyph, labels, arrow ]];
    row.translatesAutoresizingMaskIntoConstraints = NO;
    row.axis = UILayoutConstraintAxisHorizontal;
    row.alignment = UIStackViewAlignmentCenter;
    row.spacing = 12;
    [row.heightAnchor constraintGreaterThanOrEqualToConstant:64].active = YES;
    UIView *v = [self tappable:row label:title action:action];
    UIView *line = [UIView new];
    line.translatesAutoresizingMaskIntoConstraints = NO;
    line.backgroundColor = [[TYDesign color:@"A3704C"] colorWithAlphaComponent:.2];
    [v addSubview:line];
    [NSLayoutConstraint activateConstraints:@[
        [line.leadingAnchor constraintEqualToAnchor:v.leadingAnchor],
        [line.trailingAnchor constraintEqualToAnchor:v.trailingAnchor],
        [line.bottomAnchor constraintEqualToAnchor:v.bottomAnchor],
        [line.heightAnchor constraintEqualToConstant:.5]
    ]];
    return v;
}

+ (UIView *)photoCard:(NSString *)photo details:(NSArray<UIView *> *)details {
    UIView *v = [UIView new];
    v.translatesAutoresizingMaskIntoConstraints = NO;
    v.backgroundColor = [TYDesign color:@"FFDABD"];
    v.layer.cornerRadius = 22;
    v.clipsToBounds = YES;
    v.layer.borderColor = [TYDesign color:@"B57951"].CGColor;
    v.layer.borderWidth = 1;
    UIView *image = [TYDesign photo:photo height:160];
    image.layer.cornerRadius = 0;
    UIView *body = [TYDesign card:details dark:NO];
    body.layer.cornerRadius = 0;
    body.layer.borderWidth = 0;
    UIStackView *s = TYDesign.verticalStack;
    s.spacing = 0;
    [s addArrangedSubview:image];
    [s addArrangedSubview:body];
    [v addSubview:s];
    [NSLayoutConstraint activateConstraints:@[
        [s.topAnchor constraintEqualToAnchor:v.topAnchor],
        [s.bottomAnchor constraintEqualToAnchor:v.bottomAnchor],
        [s.leadingAnchor constraintEqualToAnchor:v.leadingAnchor],
        [s.trailingAnchor constraintEqualToAnchor:v.trailingAnchor]
    ]];
    return v;
}

+ (UIView *)tappable:(UIView *)content label:(NSString *)label action:(void (^)(void))action {
    UIView *v = [UIView new];
    v.translatesAutoresizingMaskIntoConstraints = NO;
    [v addSubview:content];
    content.translatesAutoresizingMaskIntoConstraints = NO;
    TYActionButton *b = [TYActionButton new];
    b.actionHandler = action;
    b.accessibilityLabel = label;
    b.backgroundColor = UIColor.clearColor;
    [v addSubview:b];
    [NSLayoutConstraint activateConstraints:@[
        [content.topAnchor constraintEqualToAnchor:v.topAnchor],
        [content.leadingAnchor constraintEqualToAnchor:v.leadingAnchor],
        [content.trailingAnchor constraintEqualToAnchor:v.trailingAnchor],
        [content.bottomAnchor constraintEqualToAnchor:v.bottomAnchor],
        [b.topAnchor constraintEqualToAnchor:v.topAnchor],
        [b.leadingAnchor constraintEqualToAnchor:v.leadingAnchor],
        [b.trailingAnchor constraintEqualToAnchor:v.trailingAnchor],
        [b.bottomAnchor constraintEqualToAnchor:v.bottomAnchor]
    ]];
    content.accessibilityElementsHidden = YES;
    return v;
}
+ (UIView *)post:(NSDictionary *)p action:(void (^)(void))action {
    NSString *status = [p[@"sample"] boolValue] ? @"示例作品 · 摄影示意"
                                                : (@{
                                                      @"pending" : @"审核中 · 仅自己可见",
                                                      @"public" : @"已公开",
                                                      @"rejected" : @"未通过 · 仅自己可见",
                                                      @"removed" : @"已下架 · 仅自己可见"
                                                  }[p[@"status"]]
                                                       ?: @"草稿");
    UIView *card = [self
        photoCard:p[@"photo"]
          details:@[
              [TYDesign pill:status],
              [TYDesign label:p[@"title"] ?: @"山野故事" size:18 weight:UIFontWeightSemibold],
              [TYDesign label:[NSString stringWithFormat:@"%@ · %@", p[@"name"] ?: @"", p[@"body"] ?: @""]
                         size:12
                       weight:UIFontWeightRegular]
          ]];
    return [self tappable:card label:p[@"title"] action:action];
}
+ (UIView *)activity:(NSDictionary *)a action:(void (^)(void))action {
    UIView *card = [self
        photoCard:a[@"photo"]
          details:@[
              [TYDesign pill:[NSString stringWithFormat:@"%@ · %@", a[@"pace"],
                                                        [TYLocalStore.sharedStore statusForActivity:a]]],
              [TYDesign label:a[@"title"] size:18 weight:UIFontWeightSemibold],
              [TYDesign label:[NSString
                                  stringWithFormat:@"%@ · %@", a[@"city"], [TYLocalStore dateText:a[@"date"]]]
                         size:12
                       weight:UIFontWeightRegular],
              [TYDesign label:[NSString stringWithFormat:@"%@ km    爬升 %@ m    %@/%@人", a[@"distance"],
                                                         a[@"climb"], a[@"joined"], a[@"capacity"]]
                         size:12
                       weight:UIFontWeightRegular],
              [TYDesign person:a[@"host"] subtitle:@"发起人提供路线信息"]
          ]];
    return [self tappable:card label:a[@"title"] action:action];
}
+ (UIView *)trip:(NSDictionary *)t action:(void (^)(void))action {
    UIView *card = [TYDesign card:@[
        [TYDesign pill:[t[@"sample"] boolValue] ? @"示例行程 · 私密" : @"本机行程 · 私密"],
        [TYDesign label:t[@"title"] size:18 weight:UIFontWeightSemibold],
        [TYDesign label:[TYLocalStore dateText:t[@"start"]] size:12 weight:UIFontWeightRegular],
        [TYDesign metrics:t]
    ]
                             dark:NO];
    return [self tappable:card label:t[@"title"] action:action];
}
@end
