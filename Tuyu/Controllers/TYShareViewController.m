#import "TYShareViewController.h"
#import "TYArtwork.h"
#import <PhotosUI/PhotosUI.h>
@interface TYShareViewController () <PHPickerViewControllerDelegate>
@end
@implementation TYShareViewController
- (void)viewDidLoad {
    NSDictionary *d = self.store.state[@"draft"];
    if (self.objectId) {
        NSDictionary *t = [self.store item:self.objectId in:@"trips"];
        if (t)
            d = @{
                @"title" : t[@"title"],
                @"body" : @"",
                @"template" : @"照片故事",
                @"photo" : t[@"photo"] ?: @"forest",
                @"tripId" : self.objectId,
                @"showMetrics" : @YES,
                @"showTip" : @NO
            };
    }
    self.values = d ? [d mutableCopy] : [@{
        @"title" : @"",
        @"body" : @"",
        @"template" : @"照片故事",
        @"photo" : @"mountain",
        @"showMetrics" : @NO,
        @"showTip" : @NO
    } mutableCopy];
    [super viewDidLoad];
}
- (void)renderContent {
    [super renderContent];
    BOOL preview = [self.screenMode isEqual:@"preview"];
    [self addBackTitle:preview ? @"公开范围预览" : @"分享卡编辑"];
    NSDictionary *t = [self.store item:self.values[@"tripId"] in:@"trips"];
    [self add:[TYDesign hero:self.values[@"photo"]
                       title:[self.values[@"title"] length] ? self.values[@"title"] : @"我的山野故事"
                    subtitle:[self.values[@"body"] length] ? self.values[@"body"]
                                                           : @"用自己的节奏，留下这一段山野。"
                       badge:self.values[@"template"] ?: @"照片故事"]];
    if ([self.values[@"showMetrics"] boolValue] && t)
        [self add:[TYDesign metrics:t]];
    if ([self.values[@"showTip"] boolValue] && [t[@"reflection"][@"tip"] length])
        [self add:[TYDesign card:@[
                  [TYDesign label:@"复盘心得" size:18 weight:UIFontWeightSemibold],
                  [TYDesign label:t[@"reflection"][@"tip"] size:14 weight:UIFontWeightRegular]
              ]
                            dark:YES]];
    __weak typeof(self) w = self;
    if (preview) {
        [self addNote:[NSString stringWithFormat:@"%@；%@。\n精确轨迹与起终点保持隐藏。",
                                                 [self.values[@"showMetrics"] boolValue] ? @"公开行程摘要"
                                                                                         : @"不公开行程摘要",
                                                 [self.values[@"showTip"] boolValue] ? @"附上已填写的心得"
                                                                                     : @"不公开复盘心得"]];
        [self addButton:@"提交内容审核"
                  style:@""
                 action:^{
                     w.store.state[@"draft"] = [w.values mutableCopy];
                     NSError *e;
                     NSString *identifier = [w.store publishDraftWithError:&e];
                     if (identifier)
                         [w pushRoute:@"postReview" identifier:identifier];
                     else
                         [w showError:e];
                 }];
        [self addButton:@"返回修改"
                  style:@"outline"
                 action:^{
                     [w.navigationController popViewControllerAnimated:YES];
                 }];
        return;
    }
    [self addChoice:@"卡片模板"
                key:@"template"
            options:@[ @"照片故事", @"路线回忆", @"极简成绩" ]
            initial:@"照片故事"];
    [self addField:@"作品标题" key:@"title" initial:nil numeric:NO limit:30];
    [self addTextArea:@"山野故事" key:@"body" initial:nil limit:1000];
    [self addButton:@"选择封面照片"
              style:@"outline"
             action:^{
                 PHPickerConfiguration *c =
                     [[PHPickerConfiguration alloc] initWithPhotoLibrary:PHPhotoLibrary.sharedPhotoLibrary];
                 c.selectionLimit = 1;
                 c.filter = PHPickerFilter.imagesFilter;
                 PHPickerViewController *picker = [[PHPickerViewController alloc] initWithConfiguration:c];
                 picker.delegate = w;
                 [w presentViewController:picker animated:YES completion:nil];
             }];
    if (t) {
        [self addSwitch:@"公开距离与用时摘要" key:@"showMetrics" initial:YES];
        [self addSwitch:@"附上一句复盘心得" key:@"showTip" initial:NO];
        [self addNote:[@"关联行程：" stringByAppendingString:t[@"title"]]];
    }
    [self addNote:@"精确轨迹、起终点、照片定位和同行者身份不会公开。"];
    [self addButton:@"预览并确认公开范围"
              style:@""
             action:^{
                 if (![w validateRequired:@[ @"title" ]])
                     return;
                 [w valuesDidChange];
                 [w pushRoute:@"sharePreview" identifier:nil];
             }];
}
- (void)valuesDidChange {
    self.store.state[@"draft"] = [self.values mutableCopy];
    [self.store commit];
}
- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSItemProvider *provider = results.firstObject.itemProvider;
    if (![provider canLoadObjectOfClass:UIImage.class])
        return;
    __weak typeof(self) w = self;
    [provider loadObjectOfClass:UIImage.class
              completionHandler:^(__kindof id<NSItemProviderReading> object, NSError *error) {
                  dispatch_async(dispatch_get_main_queue(), ^{
                      if (!w)
                          return;
                      if (error || ![object isKindOfClass:UIImage.class]) {
                          [w showError:error];
                          return;
                      }
                      NSError *saveError;
                      NSString *key = [TYArtwork saveImage:(UIImage *)object error:&saveError];
                      if (!key) {
                          [w showError:saveError];
                          return;
                      }
                      w.values[@"photo"] = key;
                      [w valuesDidChange];
                      [w renderContent];
                  });
              }];
}
@end
