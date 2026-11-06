#import "TYMarkerViewController.h"
#import "TYTrackingService.h"
#import "TYArtwork.h"
#import <PhotosUI/PhotosUI.h>
@interface TYMarkerViewController () <PHPickerViewControllerDelegate>
@end
@implementation TYMarkerViewController
- (void)renderContent {
    [super renderContent];
    [self addBackTitle:@"沿途标记"];
    if (!TYTrackingService.sharedService.session) {
        [self addNote:@"先开始一段徒步。"];
        return;
    }
    [self add:[TYDesign label:@"把这一刻，\n留在路上。" size:28 weight:UIFontWeightBold]];
    [self addChoice:@"标记类型" key:@"type" options:@[ @"风景点", @"休息点", @"随手记" ] initial:@"随手记"];
    [self addTextArea:@"沿途文字" key:@"text" initial:nil limit:300];
    __weak typeof(self) w = self;
    [self addButton:@"添加沿途照片"
              style:@"outline"
             action:^{
                 PHPickerConfiguration *c = [PHPickerConfiguration new];
                 c.filter = PHPickerFilter.imagesFilter;
                 c.selectionLimit = 1;
                 PHPickerViewController *p = [[PHPickerViewController alloc] initWithConfiguration:c];
                 p.delegate = w;
                 [w presentViewController:p animated:YES completion:nil];
             }];
    if (self.values[@"photo"])
        [self add:[TYDesign photo:self.values[@"photo"] height:180]];
    [self addButton:@"保存片刻"
              style:@""
             action:^{
                 if (![w validateRequired:@[ @"text" ]])
                     return;
                 NSMutableDictionary *s = TYTrackingService.sharedService.session;
                 if (!s) {
                     [w showMessage:@"当前没有进行中的记录。"];
                     return;
                 }
                 NSMutableDictionary *v = [w.values mutableCopy];
                 v[@"time"] = @(NSDate.date.timeIntervalSince1970);
                 [s[@"markers"] addObject:v];
                 [w.store commit];
                 [w.navigationController popViewControllerAnimated:YES];
             }];
}
- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSItemProvider *provider = results.firstObject.itemProvider;
    if (![provider canLoadObjectOfClass:UIImage.class])
        return;
    __weak typeof(self) w = self;
    [provider loadObjectOfClass:UIImage.class
              completionHandler:^(__kindof id<NSItemProviderReading> obj, NSError *error) {
                  dispatch_async(dispatch_get_main_queue(), ^{
                      if (!w)
                          return;
                      if (error || ![obj isKindOfClass:UIImage.class]) {
                          [w showError:error];
                          return;
                      }
                      NSError *e;
                      NSString *key = [TYArtwork saveImage:(UIImage *)obj error:&e];
                      if (!key) {
                          [w showError:e];
                          return;
                      }
                      w.values[@"photo"] = key;
                      [w renderContent];
                  });
              }];
}
@end
