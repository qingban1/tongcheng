#import "TYApplicationResultViewController.h"
#import "TYFeedbackViewController.h"
#import "TYDataManagementViewController.h"
#import "TYPermissionViewController.h"
#import "TYStateViewController.h"
#import "TYRouter.h"
#import "TYSquareViewController.h"
#import "TYMeetViewController.h"
#import "TYRecordsViewController.h"
#import "TYHikeViewController.h"
#import "TYMineViewController.h"
#import "TYPostViewController.h"
#import "TYShareViewController.h"
#import "TYPostReviewViewController.h"
#import "TYActivityViewController.h"
#import "TYActivityEditorViewController.h"
#import "TYApplicationViewController.h"
#import "TYActivityReviewViewController.h"
#import "TYMyActivitiesViewController.h"
#import "TYParticipantsViewController.h"
#import "TYNoticeViewController.h"
#import "TYFilterViewController.h"
#import "TYCityViewController.h"
#import "TYJournalViewController.h"
#import "TYReflectionViewController.h"
#import "TYPassportViewController.h"
#import "TYCollectionViewController.h"
#import "TYTrackingViewController.h"
#import "TYMarkerViewController.h"
#import "TYSettingsViewController.h"
#import "TYProfileViewController.h"
#import "TYMessagesViewController.h"
#import "TYLibraryViewController.h"
#import "TYInfoViewController.h"
@implementation TYRouter
+ (UIViewController *)controllerForRoute:(NSString *)route identifier:(NSString *)identifier {
    NSDictionary<NSString *, Class> *classes = @{
        @"applicationResult" : TYApplicationResultViewController.class,
        @"feedback" : TYFeedbackViewController.class,
        @"report" : TYFeedbackViewController.class,
        @"reset" : TYDataManagementViewController.class,
        @"deleteData" : TYDataManagementViewController.class,
        @"permission" : TYPermissionViewController.class,
        @"states" : TYStateViewController.class,
        @"empty" : TYStateViewController.class,
        @"offline" : TYStateViewController.class,
        @"error" : TYStateViewController.class,
        @"loading" : TYStateViewController.class,
        @"square" : TYSquareViewController.class,
        @"meet" : TYMeetViewController.class,
        @"records" : TYRecordsViewController.class,
        @"hike" : TYHikeViewController.class,
        @"mine" : TYMineViewController.class,
        @"post" : TYPostViewController.class,
        @"author" : TYPostViewController.class,
        @"share" : TYShareViewController.class,
        @"sharePreview" : TYShareViewController.class,
        @"postReview" : TYPostReviewViewController.class,
        @"activity" : TYActivityViewController.class,
        @"createActivity" : TYActivityEditorViewController.class,
        @"apply" : TYApplicationViewController.class,
        @"activityReview" : TYActivityReviewViewController.class,
        @"myActivities" : TYMyActivitiesViewController.class,
        @"participants" : TYParticipantsViewController.class,
        @"notice" : TYNoticeViewController.class,
        @"filter" : TYFilterViewController.class,
        @"city" : TYCityViewController.class,
        @"journal" : TYJournalViewController.class,
        @"summary" : TYJournalViewController.class,
        @"reflection" : TYReflectionViewController.class,
        @"passport" : TYPassportViewController.class,
        @"collection" : TYCollectionViewController.class,
        @"collectionEditor" : TYCollectionViewController.class,
        @"tracking" : TYTrackingViewController.class,
        @"recovery" : TYTrackingViewController.class,
        @"marker" : TYMarkerViewController.class,
        @"settings" : TYSettingsViewController.class,
        @"profile" : TYProfileViewController.class,
        @"messages" : TYMessagesViewController.class,
        @"myWorks" : TYLibraryViewController.class,
        @"favorites" : TYLibraryViewController.class,
        @"reviews" : TYLibraryViewController.class,
        @"blocked" : TYLibraryViewController.class
    };
    Class cls = classes[route] ?: TYInfoViewController.class;
    UIViewController *v = [cls new];
    [v setValue:identifier forKey:@"objectId"];
    NSDictionary *modes = @{
        @"author" : @"author",
        @"sharePreview" : @"preview",
        @"summary" : @"summary",
        @"collectionEditor" : @"edit",
        @"recovery" : @"recovery",
        @"myWorks" : @"works",
        @"favorites" : @"favorites",
        @"reviews" : @"reviews",
        @"blocked" : @"blocked"
    };
    NSString *mode = modes[route];
    if (cls == TYInfoViewController.class || cls == TYApplicationResultViewController.class ||
        cls == TYFeedbackViewController.class || cls == TYDataManagementViewController.class ||
        cls == TYPermissionViewController.class || cls == TYStateViewController.class)
        mode = route;
    if (mode)
        [v setValue:mode forKey:@"screenMode"];
    return v;
}
@end
