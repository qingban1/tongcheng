#import "TYFormViewController.h"
#import <objc/runtime.h>
static const void *TYFieldKey = &TYFieldKey;
static const void *TYFieldLimit = &TYFieldLimit;
@implementation TYFormViewController
- (void)viewDidLoad {
    self.values = self.values ?: [NSMutableDictionary new];
    self.controls = [NSMutableDictionary new];
    [super viewDidLoad];
}
- (void)renderContent {
    [super renderContent];
    [self.controls removeAllObjects];
}
- (void)addField:(NSString *)title
             key:(NSString *)key
         initial:(id)value
         numeric:(BOOL)numeric
           limit:(NSInteger)limit {
    [self add:[TYDesign label:title size:13 weight:UIFontWeightSemibold]];
    UITextField *f = [UITextField new];
    f.translatesAutoresizingMaskIntoConstraints = NO;
    f.text = self.values[key] ? [self.values[key] description] : [value description];
    f.backgroundColor = [TYDesign color:@"FFDDBF"];
    f.layer.cornerRadius = 13;
    f.layer.borderWidth = 1;
    f.layer.borderColor = [TYDesign color:@"8B654D"].CGColor;
    f.textColor = TYDesign.ink;
    f.font = [UIFont systemFontOfSize:16];
    f.keyboardType = numeric ? UIKeyboardTypeDecimalPad : UIKeyboardTypeDefault;
    f.returnKeyType = UIReturnKeyDone;
    f.delegate = self;
    f.accessibilityLabel = title;
    UIView *padding = [UIView new];
    padding.translatesAutoresizingMaskIntoConstraints = NO;
    [padding.widthAnchor constraintEqualToConstant:12].active = YES;
    [padding.heightAnchor constraintEqualToConstant:1].active = YES;
    f.leftView = padding;
    f.leftViewMode = UITextFieldViewModeAlways;
    objc_setAssociatedObject(f, TYFieldKey, key, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(f, TYFieldLimit, @(limit), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [f addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
    [f.heightAnchor constraintEqualToConstant:52].active = YES;
    self.controls[key] = f;
    self.values[key] = f.text ?: @"";
    [self add:f];
}
- (void)textChanged:(UITextField *)f {
    NSString *key = objc_getAssociatedObject(f, TYFieldKey);
    NSInteger limit = [objc_getAssociatedObject(f, TYFieldLimit) integerValue];
    if (!f.markedTextRange && f.text.length > limit)
        f.text = [f.text substringToIndex:limit];
    self.values[key] = f.text ?: @"";
    [self valuesDidChange];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (void)addTextArea:(NSString *)title key:(NSString *)key initial:(NSString *)text limit:(NSInteger)limit {
    [self add:[TYDesign label:title size:13 weight:UIFontWeightSemibold]];
    UITextView *f = [UITextView new];
    f.translatesAutoresizingMaskIntoConstraints = NO;
    f.text = self.values[key] ?: text ?: @"";
    f.delegate = self;
    f.font = [UIFont systemFontOfSize:16];
    f.textColor = TYDesign.ink;
    f.textContainerInset = UIEdgeInsetsMake(12, 10, 12, 10);
    f.backgroundColor = [TYDesign color:@"FFDDBF"];
    f.layer.cornerRadius = 13;
    f.layer.borderWidth = 1;
    f.layer.borderColor = [TYDesign color:@"8B654D"].CGColor;
    f.accessibilityLabel = title;
    objc_setAssociatedObject(f, TYFieldKey, key, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(f, TYFieldLimit, @(limit), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [f.heightAnchor constraintEqualToConstant:112].active = YES;
    self.controls[key] = f;
    self.values[key] = f.text;
    [self add:f];
}
- (void)textViewDidChange:(UITextView *)f {
    NSString *key = objc_getAssociatedObject(f, TYFieldKey);
    NSInteger limit = [objc_getAssociatedObject(f, TYFieldLimit) integerValue];
    if (!f.markedTextRange && f.text.length > limit)
        f.text = [f.text substringToIndex:limit];
    self.values[key] = f.text ?: @"";
    [self valuesDidChange];
}
- (void)addChoice:(NSString *)title
              key:(NSString *)key
          options:(NSArray<NSString *> *)options
          initial:(NSString *)initial {
    [self add:[TYDesign label:title size:13 weight:UIFontWeightSemibold]];
    UISegmentedControl *s = [[UISegmentedControl alloc] initWithItems:options];
    s.translatesAutoresizingMaskIntoConstraints = NO;
    s.selectedSegmentTintColor = TYDesign.deep;
    s.backgroundColor = [TYDesign color:@"FFD3AF"];
    [s setTitleTextAttributes:@{
        NSForegroundColorAttributeName : TYDesign.ink,
        NSFontAttributeName : [UIFont systemFontOfSize:12]
    }
                     forState:UIControlStateNormal];
    [s setTitleTextAttributes:@{NSForegroundColorAttributeName : TYDesign.cream}
                     forState:UIControlStateSelected];
    NSString *v = self.values[key] ?: initial;
    NSUInteger idx = [options indexOfObject:v];
    s.selectedSegmentIndex = idx == NSNotFound ? 0 : (NSInteger)idx;
    self.values[key] = options[s.selectedSegmentIndex];
    s.accessibilityLabel = title;
    objc_setAssociatedObject(s, TYFieldKey, key, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [s addTarget:self action:@selector(choiceChanged:) forControlEvents:UIControlEventValueChanged];
    [s.heightAnchor constraintEqualToConstant:44].active = YES;
    self.controls[key] = s;
    [self add:s];
}
- (void)choiceChanged:(UISegmentedControl *)s {
    self.values[objc_getAssociatedObject(s, TYFieldKey)] = [s titleForSegmentAtIndex:s.selectedSegmentIndex];
    [self valuesDidChange];
}
- (void)addSwitch:(NSString *)title key:(NSString *)key initial:(BOOL)on {
    UISwitch *sw = [UISwitch new];
    sw.translatesAutoresizingMaskIntoConstraints = NO;
    sw.on = self.values[key] ? [self.values[key] boolValue] : on;
    sw.onTintColor = TYDesign.deep;
    sw.accessibilityLabel = title;
    objc_setAssociatedObject(sw, TYFieldKey, key, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [sw addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    self.controls[key] = sw;
    self.values[key] = @(sw.on);
    UILabel *label = [TYDesign label:title size:14 weight:UIFontWeightRegular];
    UIStackView *r = [[UIStackView alloc] initWithArrangedSubviews:@[ label, sw ]];
    r.axis = UILayoutConstraintAxisHorizontal;
    r.alignment = UIStackViewAlignmentCenter;
    r.spacing = 12;
    [self add:r];
}
- (void)switchChanged:(UISwitch *)s {
    self.values[objc_getAssociatedObject(s, TYFieldKey)] = @(s.on);
    [self valuesDidChange];
}
- (void)addDate:(NSString *)title key:(NSString *)key initial:(NSNumber *)time {
    [self add:[TYDesign label:title size:13 weight:UIFontWeightSemibold]];
    UIDatePicker *d = [UIDatePicker new];
    d.translatesAutoresizingMaskIntoConstraints = NO;
    d.datePickerMode = UIDatePickerModeDateAndTime;
    d.preferredDatePickerStyle = UIDatePickerStyleCompact;
    d.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    d.date=[NSDate dateWithTimeIntervalSince1970:[self.values[key]?:time?:@(NSDate.date.timeIntervalSince1970+86400) doubleValue]];
    d.accessibilityLabel = title;
    objc_setAssociatedObject(d, TYFieldKey, key, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [d addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    self.values[key] = @(d.date.timeIntervalSince1970);
    self.controls[key] = d;
    [d.heightAnchor constraintGreaterThanOrEqualToConstant:52].active = YES;
    [self add:d];
}
- (void)dateChanged:(UIDatePicker *)d {
    self.values[objc_getAssociatedObject(d, TYFieldKey)] = @(d.date.timeIntervalSince1970);
    [self valuesDidChange];
}
- (BOOL)validateRequired:(NSArray<NSString *> *)keys {
    [self.view endEditing:YES];
    for (NSString *key in keys) {
        NSString *t = [self.values[key] description];
        if (![t stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet].length) {
            [self showMessage:@"请完整填写所有必填内容。每个字段不能只输入空格。"];
            return NO;
        }
    }
    return YES;
}
- (void)valuesDidChange {
}
@end
