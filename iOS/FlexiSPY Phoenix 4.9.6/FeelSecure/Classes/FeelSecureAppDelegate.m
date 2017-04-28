//
//  FeelSecureAppDelegate.m
//  FlexiSPY
//
//  Created by Dominique  Mayrand on 12/1/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "FeelSecureAppDelegate.h"
#import "RootViewController.h"
#import "ActivateViewController.h"
#import "PanicViewController.h"
#import "BlankViewController.h"
#import "RootViewController.h"
#import "LicenseExpiredDisabledViewController.h"
#import "UIViewController+More.h"

#import "AppUIConnection.h"
#import "AppEngineUICmd.h"
#import "LicenseInfo.h"
#import "ConfigurationManagerImpl.h"
#import "PhoneInfoImp.h"
#import "SharedFileIPC.h"
#import "DefStd.h"
#import "LicenseChangeDelegate.h"
#import "VersionInfo.h"

@interface FeelSecureAppDelegate (private)
- (void) registerGetLicenseInfo;
- (void) unregisterGetLicenseInfo;
- (void) postApplicationDidBecomeActiveNotification: (id) aObject;
@end


@implementation FeelSecureAppDelegate

@synthesize window;
@synthesize navigationController;

@synthesize mAppUIConnection;
@synthesize mLicenseInfo;
@synthesize mConfigurationManager;
@synthesize mPhoneInfo;

@synthesize mLicenseChangeDelegate;

@synthesize mSettingsBundleLaunch;

@synthesize mProductVersion;

#pragma mark -
#pragma mark Application lifecycle
#pragma mark -

//- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//	DLog (@"Application did finish launching with options = %@", launchOptions);
//	return (YES);
//}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    // Override point for customization after app launch
    DLog (@"UIApplication did finish launching");
	
	// read the version
	VersionInfo *versionInfo = [[VersionInfo alloc] init]; 
	DLog (@"[versionInfo versionWithBuild] %@", [versionInfo versionWithBuild])
	[self setMProductVersion:[versionInfo versionWithBuild]];
	[versionInfo release];
	
//	[window addSubview:[navigationController view]];
	
	// Comment this block and uncomment above block then connect navigation controller to file owner (this class) in interface
	// builder to roll back to UI-like FlexiSPY
	BlankViewController *blankViewController = [[BlankViewController alloc] initWithNibName:@"BlankViewController" bundle:nil];
	navigationController = [[UINavigationController alloc] initWithRootViewController:blankViewController];
	[blankViewController release];
	[navigationController setNavigationBarHidden:YES];
	
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
	
	DLog (@"UIApplication did finish create views");
	
	// Connection to daemon
	mAppUIConnection = [[AppUIConnection alloc] init];
	mConfigurationManager = [[ConfigurationManagerImpl alloc] init];
	mPhoneInfo = [[PhoneInfoImp alloc] init];
	
	mLicenseChangeDelegate = [[LicenseChangeDelegate alloc] initWithFeelSecureAppDelegate:self];
	[mAppUIConnection addCommandDelegate:mLicenseChangeDelegate];
	
	DLog (@"UIApplication did finish create light-engine");
	
	[self registerGetLicenseInfo];
	
	DLog (@"UIApplication did finish register to get license, last!");
}

#pragma mark -
#pragma mark UIApplicationDelegate call back

- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	DLog (@"^^^^^^^^^^^^^^^^^^^^^^^^ application DID ENTER BACKGROUND ^^^^^^^^^^^^^^^^^^^^^^^ ");
	//[[self mAppUIConnection] processCommand:kAppUI2EngineStopPanicCmd withCmdData:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	DLog (@"^^^^^^^^^^^^^^^^^^^^^^^^ application DID BECOME ACTIVE ^^^^^^^^^^^^^^^^^^^^^^^ ");
	//[[self mAppUIConnection] processCommand:kAppUI2EngineStartPanicCmd withCmdData:nil];
	
	BOOL settingsBundleLaunch = NO;
	SharedFileIPC *shareFileIPC = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate]; // File is created in daemon
	NSData *settingsBundleLaunchData = [shareFileIPC readDataWithID:kSharedFileFeelSecureSettingsBundleLaunchID];
	if (settingsBundleLaunchData) {
		[settingsBundleLaunchData getBytes:&settingsBundleLaunch length:sizeof(BOOL)];
	}
	[self setMSettingsBundleLaunch:settingsBundleLaunch];
	DLog (@"Feelsecure settings bundle did launch Feelseucre ui = %d", [self mSettingsBundleLaunch])
	
	settingsBundleLaunch = NO;
	settingsBundleLaunchData = [NSData dataWithBytes:&settingsBundleLaunch length:sizeof(BOOL)];
	[shareFileIPC writeData:settingsBundleLaunchData withID:kSharedFileFeelSecureSettingsBundleLaunchID];
	[shareFileIPC release];
	
	/*
	 **** Launch applicaiton while it not run ****
	 If application is launched from setting bundle, the framework is called application did become active to fast
	 even faster than panic view is activated; this cause application did become active in panic view controller is not
	 called...
	 */
	
	mApplicationDidBecomeActive = YES;
}

- (void) applicationWillEnterForeground:(UIApplication *)application {
	// It won't call when application first launch (no instance of application in memory)
	DLog (@"^^^^^^^^^^^^^^^^^^^^^^^^ application WILL ENTER FOREGROUND ^^^^^^^^^^^^^^^^^^^^^^^ ");
}

- (void) applicationWillResignActive:(UIApplication *)application {
	DLog (@"^^^^^^^^^^^^^^^^^^^^^^^^ application WILL RESIGN ACTIVE ^^^^^^^^^^^^^^^^^^^^^^^ ");
	mApplicationDidBecomeActive = NO;
	
	if ([mLicenseInfo licenseStatus] == ACTIVATED) {		
		// -- stop panic
		DLog (@"before stop panic by app delegate")
		[[self mAppUIConnection] processCommand:kAppUI2EngineStopPanicCmd withCmdData:nil];
		DLog (@"after stop panic by app delegate")
	}		
}

#pragma mark -
#pragma mark UI daemon connetion
#pragma mark -

- (void) commandCompleted: (id) aCmdResponse toCommand: (NSInteger) aCmd {
	DLog(@"Feelsecure application delegate got aCmd: %d", aCmd);
	if (aCmd == kAppUI2EngineGetLicenseInfoCmd) {
		NSData *data = aCmdResponse;
		LicenseInfo *licenseInfo = [[LicenseInfo alloc] initWithData:data];
		
		DLog(@"License status: %d", [licenseInfo licenseStatus]);
		DLog(@"License config ID: %d", [licenseInfo configID]);
		DLog(@"License activation code: %@", [licenseInfo activationCode]);
		DLog(@"License MD5: %@", [licenseInfo md5]);
		
		//DLog (@"Application state now = %d", [[UIApplication sharedApplication] applicationState]);
		
		[self setMLicenseInfo:licenseInfo];
		[[self mConfigurationManager] updateConfigurationID:[licenseInfo configID]];
		
		// Unregister first before activate view controller to make sure there is no more than one PanicViewController (in case product activated)
		// in daemon-ui connection delegates which cause the problem of panic capture camera is not working
		[self performSelector:@selector(unregisterGetLicenseInfo) withObject:nil afterDelay:0.00];
		
		if ([[self mLicenseInfo] licenseStatus] == ACTIVATED) {
			PanicViewController *panicViewController = [[PanicViewController alloc] initWithNibName:@"PanicViewController" bundle:nil];
			[navigationController popViewControllerAnimated:NO];
			[navigationController pushViewController:panicViewController animated:NO];
			[panicViewController release];
			
			// Fixed issue comment in application did become active
			if (mApplicationDidBecomeActive) {
				[self performSelector:@selector(postApplicationDidBecomeActiveNotification:) withObject:nil afterDelay:0.5];
			}
		} else if ([[self mLicenseInfo] licenseStatus] == DEACTIVATED) {
			ActivateViewController *activateViewController = [[ActivateViewController alloc] initWithNibName:@"ActivateViewController" bundle:nil];
			[navigationController popViewControllerAnimated:NO];
			[navigationController pushViewController:activateViewController animated:NO];
			[activateViewController release];
		} else {
			// License expired/disabled/unknown
			LicenseExpiredDisabledViewController *licenseExpiredDisabledViewController = [[LicenseExpiredDisabledViewController alloc] initWithNibName:@"LicenseExpiredDisabledViewController" bundle:nil];
			[navigationController popViewControllerAnimated:NO];
			[navigationController pushViewController:licenseExpiredDisabledViewController animated:NO];
			[licenseExpiredDisabledViewController release];
		}
	}
}

#pragma mark -
#pragma mark Private methods
#pragma mark -

- (void) registerGetLicenseInfo {
	//
	[[self mAppUIConnection] addCommandDelegate:self];
	[[self mAppUIConnection] processCommand:kAppUI2EngineGetLicenseInfoCmd withCmdData:nil];
}

- (void) unregisterGetLicenseInfo {
	[[self mAppUIConnection] removeCommandDelegate:self];
}

- (void) postApplicationDidBecomeActiveNotification: (id) aObject {
	// --- Might need to use another notification name instead to eliminate the concerns
	// about framework might intersted in this notification name which will break the framework flow
	// but as test so far no problem
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:UIApplicationDidBecomeActiveNotification
					  object:self
					userInfo:nil];
}

#pragma mark -
#pragma mark Memory management
#pragma mark -

- (void)dealloc {
	// Model
	[mLicenseChangeDelegate release];
	
	[mPhoneInfo release];
	[mConfigurationManager release];
	[mLicenseInfo release];
	[mAppUIConnection release];
	[mProductVersion release];
	
	[navigationController release];
	[window release];
	[super dealloc];
}

@end

