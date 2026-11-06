#import "TYFormViewController.h"

NS_ASSUME_NONNULL_BEGIN
@interface TYAuthViewController : TYFormViewController
@property(nonatomic, copy) NSString *destinationTitle;
@property(nonatomic, copy, nullable) void (^completion)(BOOL authenticated);
@end
NS_ASSUME_NONNULL_END
