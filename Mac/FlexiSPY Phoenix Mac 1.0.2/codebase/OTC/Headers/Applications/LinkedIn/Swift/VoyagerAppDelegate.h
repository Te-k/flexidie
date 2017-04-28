
@class UIWindow;

@interface VoyagerAppDelegate : UIResponder //<UIApplicationDelegate>
{
}

+ (void)initialize;
- (void)applicationDidReceiveMemoryWarning:(id)arg1;
- (BOOL)application:(id)arg1 openURL:(id)arg2 sourceApplication:(id)arg3 annotation:(id)arg4;
- (void)application:(id)arg1 didReceiveRemoteNotification:(id)arg2;
- (void)application:(id)arg1 didFailToRegisterForRemoteNotificationsWithError:(id)arg2;
- (void)application:(id)arg1 didRegisterForRemoteNotificationsWithDeviceToken:(id)arg2;
- (unsigned int)application:(id)arg1 supportedInterfaceOrientationsForWindow:(id)arg2;
- (void)applicationWillTerminate:(id)arg1;
- (void)applicationDidBecomeActive:(id)arg1;
- (void)applicationWillEnterForeground:(id)arg1;
- (void)applicationDidEnterBackground:(id)arg1;
- (void)applicationWillResignActive:(id)arg1;
- (BOOL)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2;

// Remaining properties
@property(retain, nonatomic) UIWindow *window;

@end
