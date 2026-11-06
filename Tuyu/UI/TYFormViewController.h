#import "TYBaseViewController.h"
NS_ASSUME_NONNULL_BEGIN
@interface TYFormViewController : TYBaseViewController <UITextFieldDelegate, UITextViewDelegate>
@property(nonatomic, strong) NSMutableDictionary *values;
@property(nonatomic, strong) NSMutableDictionary<NSString *, UIView *> *controls;
- (void)addField:(NSString *)title
             key:(NSString *)key
         initial:(nullable id)value
         numeric:(BOOL)numeric
           limit:(NSInteger)limit;
- (void)addTextArea:(NSString *)title
                key:(NSString *)key
            initial:(nullable NSString *)text
              limit:(NSInteger)limit;
- (void)addChoice:(NSString *)title
              key:(NSString *)key
          options:(NSArray<NSString *> *)options
          initial:(NSString *)initial;
- (void)addSwitch:(NSString *)title key:(NSString *)key initial:(BOOL)on;
- (void)addDate:(NSString *)title key:(NSString *)key initial:(nullable NSNumber *)time;
- (BOOL)validateRequired:(NSArray<NSString *> *)keys;
- (void)valuesDidChange;
@end
NS_ASSUME_NONNULL_END
