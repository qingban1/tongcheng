#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface TYArtwork : NSObject
+ (UIImage *)imageForKey:(nullable NSString *)key;
+ (nullable NSString *)saveImage:(UIImage *)image error:(NSError **)error;
+ (void)removeUserImages;
@end
NS_ASSUME_NONNULL_END
