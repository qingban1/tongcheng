#import "TYAppDelegate.h"
#import "TYSceneDelegate.h"
#import "TYLocalStore.h"
#import "TYLocalAuthService.h"
#import "TYTrackingService.h"
@implementation TYAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if ([NSProcessInfo.processInfo.arguments containsObject:@"--uitesting-reset"]) {
        [TYLocalAuthService.sharedService removeAccount];
        [TYLocalStore.sharedStore resetDataKeepingExamples:YES];
    } else
        [TYLocalStore sharedStore];
    [TYTrackingService sharedService];
    return YES;
}
- (UISceneConfiguration *)application:(UIApplication *)application
    configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession
                                   options:(UISceneConnectionOptions *)options {
    UISceneConfiguration *c = [[UISceneConfiguration alloc] initWithName:@"Default Configuration"
                                                             sessionRole:connectingSceneSession.role];
    c.delegateClass = TYSceneDelegate.class;
    return c;
}
@end
